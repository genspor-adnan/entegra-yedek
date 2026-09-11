import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { Bos } from './lab/detay/ortak';
import { IstemDetayi } from './lab/detay/IstemDetayi';
import { KulturDetayi } from './lab/detay/KulturDetayi';
import { GenetikDetayi } from './lab/detay/GenetikDetayi';
import { DisDetayi } from './lab/detay/DisDetayi';

/**
 * LABORATUVAR GRİD ALTI DETAY PANELİ (446).
 *
 * Mockup'ların hepsinde (Ekranlar/Lab/*.html) aynı düzen var: üstte çalışma
 * tablosu, <b>altında seçili kaydın ayrıntısı</b> - numune kabulde tetkik/tüp
 * planı, mikrobiyolojide antibiyogram ve okuma kaydı, genetikte varyantlar.
 *
 * <b>Neden gridin altında, kartta değil:</b> teknisyen elinde tüple bankoda
 * duruyor; hangi tetkiklerin hangi tüpe gittiğini görmek için kart açıp
 * kapatmak zorunda kalırsa listeyi kaybeder. Mockup bu yüzden ikisini aynı
 * ekranda gösteriyor.
 *
 * <b>Panel salt okunurdur.</b> İşlemler (kabul, ret, okuma, antibiyogram…)
 * araç çubuğu aksiyonlarıyla yapılır ve kuralları sunucuda işler; burada
 * hiçbir iş kuralı yoktur - yalnız sunucudan gelen kayıt çizilir.
 */

type Satir = Record<string, unknown>;
type Kayit = Record<string, unknown>;

/** Panelin desteklediği listeler ve detayın okunacağı anahtar. */
const KAYNAKLAR: Record<string, 'istem' | 'kultur' | 'genetik' | 'dis'> = {
  'lab-istem': 'istem',
  'lab-numune': 'istem',
  'lab-sonuc': 'istem',
  'lab-kultur': 'kultur',
  'lab-genetik-vaka': 'genetik',
  'lab-dis-gonderim': 'dis',
};

export function labDetayVarMi(kaynak: string): boolean {
  return kaynak in KAYNAKLAR;
}

/**
 * Gridin SAGINDA hasta karti YALNIZ istem tabanli listelerde vardir.
 * Kultur/genetik/dis lab panelleri kendi icinde iki sutunlu - 420px'e
 * sigmaz, gridin altinda tam genislikte kalir.
 */
export function labYanVarMi(kaynak: string): boolean {
  return KAYNAKLAR[kaynak] === 'istem';
}

/**
 * AYNI KAYDI IKI YERDE ÇİZMEK, iki kez okumak demek değildir: tetkik tablosu
 * gridin ALTINDA, hasta kartı gridin SAĞINDA durur (mockup .ucPanel) ve iki
 * bileşen aynı anda kurulur. Uçuşan istek paylaşılır - ikinci panel aynı
 * isteğin sonucunu bekler, sunucuya ikinci kez gidilmez.
 */
const ucusan = new Map<string, Promise<Kayit>>();

function labOku(tur: string, id: number): Promise<Kayit> {
  const anahtar = `${tur}:${id}`;
  const bekleyen = ucusan.get(anahtar);
  if (bekleyen) return bekleyen;
  const p = (tur === 'istem' ? api.labIstemOku(id)
           : tur === 'kultur' ? api.labKulturOku(id)
           : tur === 'genetik' ? api.genetikVakaOku(id)
           : api.disLabOku(id) as unknown as Promise<Kayit>) as Promise<Kayit>;
  const izlenen = p.finally(() => { ucusan.delete(anahtar) });
  ucusan.set(anahtar, izlenen);
  return izlenen;
}

/**
 * `kisim`: panel gridin neresinde çiziliyor.
 * <b>ana</b> = gridin altı (tetkik/antibiyogram/varyant tabloları),
 * <b>yan</b> = gridin sağı (hasta kartı, etiketler, kurallar),
 * <b>tam</b> = ikisi yan yana (eski düzen; istem dışı kayıtlar).
 */
export function LabDetayPaneli({ kaynak, satir, kisim = 'tam' }: {
  kaynak: string;
  satir: Satir | null;
  kisim?: 'tam' | 'ana' | 'yan';
}) {
  const tur = KAYNAKLAR[kaynak];
  // İstem tabanlı listelerde detay İSTEMİN kendisidir: numune ve sonuç
  //   satırları da aynı istemin parçası (barkod tek başına yetmez - bir
  //   istemde birden çok tüp olur).
  const id = tur === 'istem'
    ? Number(satir?.istemId ?? (kaynak === 'lab-istem' ? satir?.id : 0) ?? 0)
    : Number(satir?.id ?? 0);

  const [veri, setVeri] = useState<Kayit | null>(null);
  const [hata, setHata] = useState('');
  const [yukleniyor, setYukleniyor] = useState(false);

  const yukle = useCallback(async () => {
    if (!tur || !id) { setVeri(null); return }
    setYukleniyor(true); setHata('');
    try {
      setVeri(await labOku(tur, id));
    } catch (h) { setHata(hataMetni(h)); setVeri(null) }
    finally { setYukleniyor(false) }
  }, [tur, id]);

  useEffect(() => { void yukle() }, [yukle]);

  if (!tur) return null;
  // İstem dışı kayıtlarda (kültür, genetik, dış lab) yan kolon YOKTUR:
  //   o panellerin kendi düzeni iki sütunlu, gridin sağına sığmaz.
  if (kisim === 'yan' && tur !== 'istem') return null;
  // Satir secili degilken de kutu cizilir: yan kolon kaybolursa grid
  //   genisleyip her secimde yeniden daralir - ekran zipliyor gorunurdu.
  if (!id)
    return <div className="lab-detay"><Bos ne="Ayrıntı için listeden bir satır seçin." /></div>;

  return (
    <div className="lab-detay">
      {hata && <div className="hata-kutusu">{hata}</div>}
      {!veri && yukleniyor && <Bos ne="Yükleniyor…" />}
      {veri && tur === 'istem' &&
        <IstemDetayi veri={veri} secili={satir} kaynak={kaynak} kisim={kisim} />}
      {veri && tur === 'kultur' && <KulturDetayi veri={veri} />}
      {veri && tur === 'genetik' && <GenetikDetayi veri={veri} />}
      {veri && tur === 'dis' && <DisDetayi veri={veri} />}
    </div>
  );
}

/* ------------------------------------------------------------------ istem --
   Mockup lab_istem_numune_kabul.html: solda "LAB-…/… · Tetkikler" tablosu
   (tüp planı otomatik), sağda hasta/klinik bilgisi ve etiketler.        */
