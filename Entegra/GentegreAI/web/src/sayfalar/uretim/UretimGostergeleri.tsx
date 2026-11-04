import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { EmirOzeti, FisOzeti } from '../../api/uclar/uretimFisi';
import type { AgacOzeti } from '../../api/uclar/uretim';
import { ImzaPenceresi } from '../../bilesenler/ImzaPenceresi';
import { mesaj } from '../../bilesenler/mesaj';
import { para, sayi } from '../../bilesenler/bicim';
import { useUretimSeviyesi } from '../../bilesenler/useUretimSeviyesi';
import { c } from '../../dil/ceviri';
import { FisSerbestPenceresi } from './UretimFisiPanelleri';
import { ReceteIslemPenceresi } from './UrunAgaciPanelleri';
import { UA_ISLEM_OLAYI, UE_ISLEM_OLAYI, UF_ISLEM_OLAYI, cipIndeksi, uretimListeUyarlamasi, type UretimIslemOlayi } from './uretimListeSeviye';

/**
 * ÜRETİM LİSTELERİNİN ÜST PANELİ (1254, mockup `.ozet` kutuları): sayaçlar kurum genelini sayar, kutuya tıklamak listeyi
 * o cipe süzer (KasaGostergesi deseni). Seviyeye göre kutu: denetimlide Karantina, basit / standartta Toplam maliyet.
 *
 * Liste aksiyonlarının e-imza pencereleri de burada: aksiyon işleyicisi (uretimAksiyonlari.ts) pencere çizemez,
 * olay atar; panel dinler ve ImzaPenceresi'ni açar (KonsultasyonUstPanel deseni).
 */
const kisa = (n: number) => (Math.abs(n) >= 1e6 ? `${sayi.format(Math.round(n / 1e5) / 10)} M` : para.format(n));

interface Kutu { cip: number | null; deger: string; ad: string; ek?: string; sinif?: string }

function Kutular({ kutular, cipIndeks, onCip, tumu }: { kutular: Kutu[]; cipIndeks?: number; onCip(i: number): void; tumu: number }) {
  return (
    <div className="pl-kpi ml-kpi">
      {kutular.map(k => (
        <button key={k.ad} type="button" disabled={k.cip === null}
                className={`pl-k${k.cip !== null && cipIndeks === k.cip ? ' on' : ''}${k.sinif ? ` ${k.sinif}` : ''}`}
                title={k.cip !== null ? c('Listeyi bu kümeye süz (tekrar tıkla: tümü)') : undefined}
                onClick={() => k.cip !== null && onCip(cipIndeks === k.cip ? tumu : k.cip)}>
          <b>{k.deger}</b><span>{c(k.ad)}{k.ek ? ` · ${k.ek}` : ''}</span>
        </button>))}
    </div>
  );
}

function useIslemOlayi(ad: string) {
  const [islem, setIslem] = useState<UretimIslemOlayi | null>(null);
  useEffect(() => {
    const dinle = (e: Event) => setIslem((e as CustomEvent<UretimIslemOlayi>).detail);
    window.addEventListener(ad, dinle);
    return () => window.removeEventListener(ad, dinle);
  }, [ad]);
  return [islem, setIslem] as const;
}

export function UretimEmirGostergesi({ yenile, cipIndeks, onCip, tazele }: { yenile: number; cipIndeks?: number; onCip(i: number): void; tazele(): void }) {
  const sv = useUretimSeviyesi();
  const [g, setG] = useState<EmirOzeti | null>(null);
  const [islem, setIslem] = useIslemOlayi(UE_ISLEM_OLAYI);
  useEffect(() => { api.uretimEmirOzet().then(setG).catch(() => setG(null)) }, [yenile]);
  const cipler = uretimListeUyarlamasi('uretim-emri', sv.seviye)?.cipler ?? [];
  const cip = (ad: string) => cipIndeksi(cipler, ad);
  const tumu = cip('Tümü') ?? 0;
  const oran = g && g.plan > 0 ? Math.round(g.uretilen * 100 / g.plan) : 0;
  const kutular: Kutu[] = [
    { cip: cip('Açık'), deger: g ? sayi.format(g.acik) : '…', ad: 'Açık emir',
      ek: g ? `${g.uretimde} ${c('üretimde')} · ${g.onayli} ${c('onaylı')}${sv.denetimli ? ` · ${g.serbest} ${c('serbest')}` : ''} · ${g.taslak} ${c('taslak')}` : undefined },
    { cip: null, deger: g ? `${sayi.format(g.plan)} / ${sayi.format(g.uretilen)}` : '…', ad: 'Plan / üretilen', ek: g ? `%${oran}` : undefined },
    { cip: cip('Geciken'), deger: g ? sayi.format(g.geciken) : '…', ad: 'Termini geçen',
      ek: g?.gecikenNo ? `${g.gecikenNo} · ${g.gecikenGun} ${c('gün')}` : undefined, sinif: g?.geciken ? 'kirmizi' : undefined },
    ...(sv.denetimli
      ? [{ cip: null, deger: g ? `${sayi.format(g.karantinaParti)} ${c('parti')} · ${sayi.format(g.karantinaAdet)} ${c('ad.')}` : '…',
           ad: 'Karantina', ek: c('kalite onayı bekliyor'), sinif: g?.karantinaParti ? 'uyari' : undefined } as Kutu]
      : [{ cip: null, deger: g ? `%${sayi.format(g.malzemeHazirlik)}` : '…', ad: 'Malzeme hazırlık',
           ek: g ? `${g.malzemeEksik} ${c('emirde eksik')}` : undefined, sinif: g?.malzemeEksik ? 'uyari' : undefined } as Kutu]),
  ];
  return (
    <>
      <Kutular kutular={kutular} cipIndeks={cipIndeks} onCip={onCip} tumu={tumu} />
      {islem?.islem === 'serbest' && (
        /* SERBEST BIRAKMA (liste aksiyonu, denetimli): ön kontroller sunucuda; gerekçe + parola (e-imza). */
        <ImzaPenceresi baslik={c('Atölyeye serbest bırak')} parolaIster={sv.denetimli} gerekceZorunlu={sv.denetimli}
          onaylaMetni={() => `🏁 ${c(sv.denetimli ? 'İmzala ve serbest bırak' : 'Serbest bırak')}`}
          aciklama={c('Durum Onaylı → Serbest bırakıldı; sonra "Üretime Başlat". Ön kontroller sunucuda doğrulanır; geçmeyen varsa sebebi söylenir.')}
          onKapat={() => setIslem(null)}
          onImzala={async (gerekce, parola) => { const y = await api.uretimEmriSerbestBirak(islem.id, gerekce, parola); mesaj(y.mesaj); setIslem(null); tazele() }} />)}
    </>
  );
}

export function UretimFisiGostergesi({ yenile, cipIndeks, onCip, tazele }: { yenile: number; cipIndeks?: number; onCip(i: number): void; tazele(): void }) {
  const sv = useUretimSeviyesi();
  const [g, setG] = useState<FisOzeti | null>(null);
  const [islem, setIslem] = useIslemOlayi(UF_ISLEM_OLAYI);
  useEffect(() => { api.uretimFisOzet().then(y => setG(y.ozet)).catch(() => setG(null)) }, [yenile]);
  const cipler = uretimListeUyarlamasi('uretim-fisi', sv.seviye)?.cipler ?? [];
  const cip = (ad: string) => cipIndeksi(cipler, ad);
  const tumu = cip('Tümü') ?? 0;
  const kutular: Kutu[] = [
    { cip: tumu, deger: g ? sayi.format(g.fis) : '…', ad: 'Fiş (bu ay)',
      ek: g ? `${g.taslak} ${c('taslak')}${g.tersKayit ? ` · ${g.tersKayit} ${c('ters kayıt')}` : ''}` : undefined },
    { cip: cip('İşlenen') ?? cip('Serbest'), deger: g ? sayi.format(g.uretilen) : '…', ad: 'Üretilen',
      ek: g ? `${g.mamul} ${c('mamul')}${g.yanUrun ? ` · ${g.yanUrun} ${c('yan ürün')}` : ''}` : undefined },
    { cip: null, deger: g ? kisa(g.malzeme) : '…', ad: 'Malzeme', ek: c('sarf + normal fire') },
    { cip: null, deger: g ? kisa(g.iscilik) : '…', ad: 'İşçilik / gider', ek: c('operasyonlardan') },
    ...(sv.denetimli
      ? [{ cip: cip('Kalite bekleyen'), deger: g ? `${sayi.format(g.karantinaParti)} ${c('parti')}` : '…', ad: 'Karantina',
           ek: g ? `${c('kalite onayı bekliyor')} · ${sayi.format(g.karantinaAdet)} ${c('adet')}${g.reddedilen ? ` · ${g.reddedilen} ${c('ret')}` : ''}` : undefined,
           sinif: g?.karantinaParti ? 'uyari' : undefined } as Kutu]
      : [{ cip: null, deger: g ? kisa(g.toplam) : '…', ad: 'Toplam maliyet',
           ek: g && g.uretilen > 0 ? `${c('ort. birim')} ${para.format(g.toplam / g.uretilen)}` : undefined } as Kutu]),
  ];
  // Listedeki "Kalite" kolonu "uygun / toplam" yazar; serbest bırakma kararı kontroller tamamken açılır.
  const kalite = String(islem?.satir?.kalite ?? '');
  const [uygun, toplam] = kalite.split('/').map(x => Number(x.trim()));
  const kontrolTamam = Number.isFinite(uygun) && Number.isFinite(toplam) && toplam > 0 && uygun === toplam;
  return (
    <>
      <Kutular kutular={kutular} cipIndeks={cipIndeks} onCip={onCip} tumu={tumu} />
      {islem?.islem === 'serbest' && (
        <FisSerbestPenceresi fisId={islem.id} kontrolTamam={kontrolTamam} onKapat={() => setIslem(null)} onBitti={() => { setIslem(null); tazele() }} />)}
      {islem?.islem === 'ters' && (
        /* GEREKÇELİ TERS KAYIT (denetimli): belgeler geri alınır, fiş durum 0 ile iz kalır. */
        <ImzaPenceresi baslik={c('Ters kayıt — gerekçe')} parolaIster={false} gerekceZorunlu
          onaylaMetni={() => `↺ ${c('Ters kayıt at')}`}
          aciklama={c('Sarf, fire ve üretim girişi belgeleri geri alınır; fiş silinmez, "Ters kayıt" durumuyla kalır. Mamul stoktan çıkmışsa sunucu reddeder.')}
          onKapat={() => setIslem(null)}
          onImzala={async gerekce => { const y = await api.uretimFisTersKayit(islem.id, gerekce); mesaj(y.mesaj); setIslem(null); tazele() }} />)}
    </>
  );
}

/**
 * REÇETE LİSTESİ ÜST ŞERİDİ (1257, mockup urun_agaci_listesi_v2.html `.ozet`): seviyeye göre kutular - basit: Reçete ·
 * Boş reçete · Bu ay üretilen · Malzeme eksik; standart: Reçete · Boş · Maliyeti eski · Açık emirde; denetimli: + Onay
 * bekleyen. Pasife Al / Onaya Gönder / Onayla pencereleri de burada (liste aksiyonu olay atar).
 */
export function UrunAgaciGostergesi({ yenile, cipIndeks, onCip, tazele }: { yenile: number; cipIndeks?: number; onCip(i: number): void; tazele(): void }) {
  const sv = useUretimSeviyesi();
  const [g, setG] = useState<AgacOzeti | null>(null);
  const [islem, setIslem] = useIslemOlayi(UA_ISLEM_OLAYI);
  useEffect(() => { api.uretimAgacOzet().then(y => setG(y.ozet)).catch(() => setG(null)) }, [yenile]);
  const cipler = uretimListeUyarlamasi('urun-agaci', sv.seviye)?.cipler ?? [];
  const cip = (ad: string) => cipIndeksi(cipler, ad);
  const tumu = cip('Tümü') ?? 0;
  const kutular: Kutu[] = [
    { cip: cip('Aktif'), deger: g ? sayi.format(g.recete) : '…', ad: 'Reçete', ek: g ? `${g.aktif} ${c('aktif')} · ${g.pasif} ${c('pasif')}` : undefined },
    { cip: null, deger: g ? sayi.format(g.bos) : '…', ad: 'Boş reçete', ek: c('bileşeni yok - üretilemez'), sinif: g?.bos ? 'uyari' : undefined },
    ...(sv.basit
      ? [{ cip: null, deger: g ? sayi.format(g.buAyUretilen) : '…', ad: 'Bu ay üretilen', ek: g ? `${g.buAyFis} ${c('fiş')}` : undefined } as Kutu,
         { cip: cip('Malzeme eksik'), deger: g ? sayi.format(g.malzemeEksik) : '…', ad: 'Malzeme eksik', ek: c('reçete - bugün üretilemez'),
           sinif: g?.malzemeEksik ? 'uyari' : undefined } as Kutu]
      : [{ cip: cip('Maliyeti eski'), deger: g ? sayi.format(g.maliyetEski) : '…', ad: 'Maliyeti eski', ek: c('son hesap > 30 gün'),
           sinif: g?.maliyetEski ? 'uyari' : undefined } as Kutu,
         { cip: cip('Açık emirde'), deger: g ? sayi.format(g.acikEmirde) : '…', ad: 'Açık emirde', ek: g ? `${c('reçete')} · ${g.acikEmir} ${c('emir')}` : undefined } as Kutu]),
    ...(sv.denetimli
      ? [{ cip: cip('Onay bekleyen'), deger: g ? sayi.format(g.onayBekleyen) : '…', ad: 'Onay bekleyen',
           ek: g?.onayBekleyen ? `${c('en eski')} ${g.onayBekleyenGun} ${c('gün')}` : undefined, sinif: g?.onayBekleyen ? 'kirmizi' : undefined } as Kutu]
      : []),
  ];
  const kod = String(islem?.satir?.kod ?? '');
  return (
    <>
      <Kutular kutular={kutular} cipIndeks={cipIndeks} onCip={onCip} tumu={tumu} />
      {islem && (islem.islem === 'pasif' || islem.islem === 'onaya-gonder' || islem.islem === 'onayla' || islem.islem === 'uret') && (
        <ReceteIslemPenceresi islem={islem.islem} id={islem.id} kod={kod} onayDurum={Number(islem.satir?.onayDurum ?? 0)} satir={islem.satir}
                              onKapat={() => setIslem(null)} onBitti={() => { setIslem(null); tazele() }} />)}
    </>
  );
}
