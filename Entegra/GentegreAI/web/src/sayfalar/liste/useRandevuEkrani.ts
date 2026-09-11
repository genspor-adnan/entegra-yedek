import { useEffect, useMemo, useState } from 'react';
import { api } from '../../api/istemci';
import { guvenli, mesaj } from '../../bilesenler/mesaj';
import type { Kosul, RandevuBolumDugumu } from '../../api/sozlesme';
import type { BekleyenIstem } from '../../bilesenler/radyoloji/RandevuBekleyenPanel';

/**
 * RANDEVU EKRANI (243 · 251 · 316): ust seridin bolum/hekim suzgeci, takvim
 * ayarlari, cihaz sutunlari ve bekleyen isteme randevu verme.
 *
 * Randevu suzgecleri gride ve takvime AYNI kosulu verir: ust seritte ne
 * seciliyse alttaki takvim de onu gosterir - iki ayri suzgec kafa karistirir.
 * Bu yuzden filtre de burada uretilir.
 */
export function useRandevuEkrani(
  kaynak: string,
  sabitFiltre: Kosul | undefined,
  tazele: () => void,
) {
  const randevuEkrani = kaynak === 'randevu';

  // RANDEVU TAKVIMI (243) ayarlari: takvim saat araligi/calisma gunleri
  //   Randevu Ayarlari ekranindan (referans) gelir.
  const [ayarlar, setAyarlar] = useState<{
    baslangicSaat?: string; bitisSaat?: string; slotDk?: number; calismaGunleri?: number[];
  }>({});
  // RANDEVU (251, kullanici: "bu bölüm ve hekimler randevu listesi üst tarafta
  //   tarih sağında listelenip filtrelensin"): tek uctan hem bolum hem hekim
  //   listesi gelir (Randevu Ayarlari > Bölümler ile ayni kaynak).
  const [agac, setAgac] = useState<RandevuBolumDugumu[]>([]);
  const [bolum, setBolum] = useState<number | ''>('');
  const [hekim, setHekim] = useState<number | ''>('');
  /** Takvimde fareyle secilen aralik (251): "＋ Yeni" bunu karta tasir. */
  const [aralik, setAralik] = useState<{ baslangic: string; sureDk: number;
                                         hekimId?: number; cihazId?: number } | null>(null);
  /**
   * RADYOLOJI CIHAZLARI (316): takvimin "Cihaz" gorunumunun sutunlari.
   * Radyoloji kurulu degilse liste bos doner, buton da cikmaz.
   */
  const [cihazlar, setCihazlar] = useState<{ id: number; ad: string }[]>([]);
  /**
   * Takvimin yan panelinde (316) seçili bekleyen istem: takvimde boş saate
   * tıklanınca yeni randevu formu yerine BU isteme randevu verilir.
   */
  const [bekleyenSecili, setBekleyenSecili] = useState<BekleyenIstem | null>(null);

  useEffect(() => {
    if (!randevuEkrani) return;
    let iptal = false;
    api.randevuBolumleri()
      .then(y => { if (!iptal) setAgac(y) })
      .catch(() => { /* bolum listesi okunamazsa suzgecler bos kalir */ });
    return () => { iptal = true };
  }, [randevuEkrani]);

  useEffect(() => {
    if (!randevuEkrani) return;
    let iptal = false;
    api.ayarlar().then(liste => {
      if (iptal) return;
      const bul = (a: string) => liste.find(x => x.anahtar === a)?.deger ?? '';
      const gunler = bul('randevu.calisma_gunleri')
        .split(',').map(x => Number(x.trim())).filter(x => x >= 1 && x <= 7);
      setAyarlar({
        baslangicSaat: bul('randevu.baslangic_saat') || undefined,
        bitisSaat: bul('randevu.bitis_saat') || undefined,
        slotDk: Number(bul('randevu.slot_dk')) || undefined,
        calismaGunleri: gunler.length ? gunler : undefined,
      });
    }).catch(() => { /* ayar okunamazsa takvim varsayilanla calisir */ });
    return () => { iptal = true };
  }, [randevuEkrani]);

  // Cihaz listesi randevu ekraninda bir kez cekilir; yetki/veri yoksa sessiz
  //   gecilir - poliklinik kurulumunda cihaz olmamasi hata degildir.
  useEffect(() => {
    if (!randevuEkrani) return;
    let iptal = false;
    void (async () => {
      try {
        const y = await api.liste('radyoloji-cihaz', {
          sayfa: 1, boyut: 50,
          filtre: { op: 'and', kosullar: [
            { alan: 'durum', op: 'esit', deger: 1 },
            { alan: 'randevuVerilir', op: 'esit', deger: 1 },
          ] },
        });
        if (!iptal)
          setCihazlar(y.satirlar.map(r => ({
            id: Number(r.id), ad: String(r.ad ?? r.kod ?? ''),
          })));
      } catch { /* radyoloji yok ya da yetki yok - cihaz gorunumu cikmaz */ }
    })();
    return () => { iptal = true };
  }, [randevuEkrani]);

  const filtre = useMemo<Kosul | undefined>(() => {
    if (!randevuEkrani) return sabitFiltre;
    const kosullar: Kosul[] = [];
    if (sabitFiltre) kosullar.push(sabitFiltre);
    if (bolum !== '') kosullar.push({ alan: 'bolum', op: 'esit', deger: bolum });
    if (hekim !== '') kosullar.push({ alan: 'hekimId', op: 'esit', deger: hekim });
    return kosullar.length === 0 ? undefined
         : kosullar.length === 1 ? kosullar[0]
         : { op: 'and', kosullar };
  }, [randevuEkrani, sabitFiltre, bolum, hekim]);

  /**
   * Takvimin kullanacagi ayar: HEKIM -> BÖLÜM -> Genel Ayarlar sirasiyla miras
   * alinir (251). Hekim ogle arasini degistirdiyse takvim o hekim secildiginde
   * onu gostermeli - yoksa bolum duzeni sanilir.
   */
  const takvimAyarlari = useMemo(() => {
    const bolumDugum = bolum === '' ? undefined
      : agac.find(d => d.departmanId === bolum);
    const hekimAyar = hekim === ''
      ? undefined
      : (bolumDugum ?? agac.find(d => d.hekimler.some(h => h.hekimId === hekim)))
          ?.hekimler.find(h => h.hekimId === hekim);
    const oncelikli = (...adaylar: (string | number | null | undefined)[]) =>
      adaylar.find(v => v !== '' && v !== null && v !== undefined);
    const gunler = String(oncelikli(hekimAyar?.calismaGunleri, bolumDugum?.ayar.calismaGunleri) ?? '')
      .split(',').map(x => Number(x.trim())).filter(x => x >= 1 && x <= 7);
    return {
      ...ayarlar,
      baslangicSaat: oncelikli(hekimAyar?.baslangicSaat, bolumDugum?.ayar.baslangicSaat) as string
                     ?? ayarlar.baslangicSaat,
      bitisSaat: oncelikli(hekimAyar?.bitisSaat, bolumDugum?.ayar.bitisSaat) as string
                 ?? ayarlar.bitisSaat,
      slotDk: (oncelikli(hekimAyar?.slotDk, bolumDugum?.ayar.slotDk) as number)
              ?? ayarlar.slotDk,
      calismaGunleri: gunler.length ? gunler : ayarlar.calismaGunleri,
    };
  }, [agac, ayarlar, bolum, hekim]);

  /** Bolum secilince hekim listesi o bolume daralir. */
  const hekimSecenekleri = useMemo(() => {
    const dugumler = bolum === '' ? agac : agac.filter(d => d.departmanId === bolum);
    // Hekimin BOLUMU de tasinir: takvimde bir hekim sutununda saat secilince
    //   kartta bolum de dolu gelsin (kullanici: "dr bolumu belli, kartta
    //   bolumu doldursun").
    return dugumler.flatMap(d =>
      d.hekimler.map(h => ({ id: h.hekimId ?? 0, ad: h.ad, bolum: d.departmanId })));
  }, [agac, bolum]);

  /** Hekimin bolumu (takvim sutunundan gelen hekim icin). */
  const hekimBolumu = (h?: number) =>
    h ? hekimSecenekleri.find(x => x.id === h)?.bolum : undefined;

  /**
   * BEKLEYEN İSTEME RANDEVU (316): panelden sürükle-bırak ve "seç + boş saate
   * tıkla" yollarının ortak ucu. Süre istemin çekim protokolünden (314) gelir;
   * çakışma/kapasite/cihaz kapatma kuralları veritabanı tetiğindedir - buradan
   * tekrar kontrol edilmez, hata mesajı olduğu gibi gösterilir.
   */
  const bekleyeneRandevuVer = async (
    istem: BekleyenIstem, baslangic: string, cihazId?: number,
  ) => {
    if (!cihazId) {
      mesaj('Randevu cihaza verilir - takvimde bir cihaz sütunu seçin.');
      return;
    }
    const ok = await guvenli(() => api.radyolojiRandevuVer(istem.id, {
      cihazId, baslangic,
      sureDk: istem.sureDk > 0 ? istem.sureDk : undefined,
    }));
    if (!ok) return;
    mesaj(`Randevu verildi: ${istem.hasta} · ${baslangic.slice(11)} `
          + `(${istem.accessionNo})`);
    setBekleyenSecili(null);
    tazele();
  };

  return { agac, bolum, setBolum, hekim, setHekim, aralik, setAralik,
           cihazlar, bekleyenSecili, setBekleyenSecili,
           filtre, takvimAyarlari, hekimSecenekleri, hekimBolumu, bekleyeneRandevuVer };
}

export type RandevuEkrani = ReturnType<typeof useRandevuEkrani>;
