import { useEffect, useMemo, useState } from 'react';
import { c, cm } from '../dil/ceviri';
import { guvenli, mesaj, metinSor, onay } from '../bilesenler/mesaj';
import { useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { GenGrid } from '../bilesenler/GenGrid';
import { RandevuTakvimi } from '../bilesenler/RandevuTakvimi';
import { GenForm } from '../bilesenler/GenForm';
import {
  type EBelgeMesaji, type Kosul, type ListeSatiri, type RandevuBolumDugumu, hataMetni,
} from '../api/sozlesme';
import { api } from '../api/istemci';
import { BelgeDonusumModali } from '../bilesenler/BelgeDonusumModali';
import { IceriAlModali } from '../bilesenler/IceriAlModali';
import { UtsAlmaModali } from '../bilesenler/uts/UtsAlmaModali';
import { UtsKullanimModali } from '../bilesenler/uts/UtsBildirimModallari';
import { UtsGenelBildirimModali, type UtsBildirimTuru }
  from '../bilesenler/uts/UtsGenelBildirimModali';
import { UtsBelgeSonucModali } from '../bilesenler/uts/UtsBelgeSonucModali';
import { UtsHazirlaSonucModali } from '../bilesenler/uts/UtsHazirlaSonucModali';
import type { UtsBelgeBildirimYaniti, UtsHazirlaYaniti } from '../api/istemci';
import { dosyaIndirUrl } from '../bilesenler/indir';
import { ebelgeCiktisi } from './ebelgeIslem';
import { gelenBelgeAksiyonu } from './gelenBelgeIslem';
import { Modal } from '../bilesenler/Modal';
import { BelgeKarti } from './BelgeKarti';
import { KasaIslemKarti } from './KasaIslemKarti';
import { DONUSUM_MENUSU, KASA_ARAC_MENUSU, LISTELER, type ListeTanimi }
  from './listeTanimlari';

// Tanimlar ayri dosyada (listeTanimlari); disaridan alisilmis yol bozulmasin
//   diye buradan da disa aktarilir (App.tsx / Kabuk.tsx LISTELER'i buradan alir).
export { LISTELER };

/** Kirilma yolu ("Satis › Satış Faturaları") parca parca cevrilir: ayrac
    korunur, her parca menu sozlugunden gecer. */
function yolCevir(yol: string | undefined): string | undefined {
  if (!yol) return yol;
  return yol.split('›').map(p => cm(p.trim())).join(' › ');
}
export type { ListeTanimi };

/**
 * Tek bilesen tum liste ekranlarini karsilar. Kolonlar, filtreler ve yetki
 * sunucudan geldigi icin ekran basina kod yazmaya gerek yok — yeni bir liste
 * eklemek katalogda kaynak tanimlamak + burada bir satir demek.
 */
export function Liste({ tanim }: { tanim: ListeTanimi }) {
  const git = useNavigate();
  const { id } = useParams();
  const [sorgu] = useSearchParams();

  // Kart MODAL acilir (mockup deseni): liste arkada kalir, URL yine /cari/4911.
  const kartId = id === undefined ? null : (id === 'yeni' ? 'yeni' as const : Number(id));

  // Ekstre ekranlari: /hesap-ekstre?hesapId=12 -> sunucu filtresi. Tanimdaki
  //   sabitFiltre ile birlikte gelirse ikisi AND'lenir.
  const urlDegeri = tanim.urlFiltreAlani ? sorgu.get(tanim.urlFiltreAlani) : null;
  const sabitFiltre = useMemo<Kosul | undefined>(() => {
    if (!tanim.urlFiltreAlani || !urlDegeri) return tanim.sabitFiltre;
    const urlKosul: Kosul = { alan: tanim.urlFiltreAlani, op: 'esit', deger: Number(urlDegeri) };
    return tanim.sabitFiltre
      ? { op: 'and', kosullar: [tanim.sabitFiltre, urlKosul] }
      : urlKosul;
  }, [tanim.urlFiltreAlani, tanim.sabitFiltre, urlDegeri]);

  // Kart kaydedilince (ekleme ya da duzenleme) grid'i yeniden yukletmek icin - GenForm
  //   onKaydedildi'de bir arttirilir, GenGrid bu degisimi izleyip yukle() cagirir.
  const [yenile, setYenile] = useState(0);
  // Yeni kart EKLENINCE (duzenlemede degil) grid "Son Aranan"a gecsin - kullanici
  //   az once ekledigi kaydi listede otomatik en ustte gorsun.
  const [odaklaSonEklenen, setOdaklaSonEklenen] = useState(0);
  /** Excel'den iceri alma modali (207) - fiyat listesi; null iken kapali. */
  const [iceriAl, setIceriAl] = useState<{ listeId: number; ad: string } | null>(null);
  // ÜTS alma bildirimi (223): askidaki envanter satirindan modal.
  const [utsAlma, setUtsAlma] = useState<{ envanterId: number; urunNo: string;
    kurumUnvan: string; askiAdet: number; seriNo: string } | null>(null);
  const [utsKullanim, setUtsKullanim] = useState(false);
  const [utsGenel, setUtsGenel] = useState<UtsBildirimTuru | null>(null);
  // Verme hazirlama raporu (atlananlar gridi + CSV).
  const [utsHazirla, setUtsHazirla] = useState<UtsHazirlaYaniti | null>(null);
  // Belge koprusu sonucu (226): satir satir verme/alma raporu.
  const [utsBelgeSonuc, setUtsBelgeSonuc] = useState<UtsBelgeBildirimYaniti | null>(null);
  // Donusum modali (F8): siparis/irsaliye satirlarindan yeni belge uretir.
  /** Mesaj gecmisi penceresi (178) - null iken kapali. */
  const [eBelgeMesajlari, setEBelgeMesajlari] =
    useState<{ belgeNo: string; satirlar: EBelgeMesaji[] } | null>(null);
  const [donusum, setDonusum] =
    useState<{ belgeId: number; belgeTur: number; hedef?: number } | null>(null);
  // Belge (fatura/siparis) karti da MODAL: liste arkada kalir, rota degismez.
  const [yeniBelgeTuru, setYeniBelgeTuru] = useState<number | null>(null);
  // Mevcut belgeyi ac (salt gorunum) - ayni modal, id ile.
  const [acikBelgeId, setAcikBelgeId] = useState<number | null>(null);
  // Kasa islem karti MODAL (tahsilat/odeme): liste arkada acik kalir.
  const [kasaTuru, setKasaTuru] = useState<number | null>(null);
  // Ekstre satirindan acilan MEVCUT kasa islemi (salt gorunum/duzenleme).
  const [acikKasaId, setAcikKasaId] = useState<number | null>(null);
  /** Cek/senet ile tahsilat-odemede once acilan KIYMET KARTININ turu (23/24/33/34). */
  const [cekTuru, setCekTuru] = useState<number | null>(null);
  /** Kiymet kaydedildikten sonra acilan kasa islemi (ayni kiymete bagli). */
  const [kasaAcilis, setKasaAcilis] = useState<{
    tur: number; tarafId?: number; tarafUnvan?: string; tutar?: string; cekSenetId?: number;
  } | null>(null);

  /**
   * Kiymet karti kaydedildi: ayni bilgilerle kasa islemini ac. Kart SUNUCUDAN
   * yeniden okunur - tutar/cari/doviz kullanicinin kartta girdigi son hali
   * olsun (formdaki ara degerler degil).
   */
  async function cekKartKaydedildi(tur: number, id: number) {
    setCekTuru(null);
    setYenile(t => t + 1);
    try {
      const k = await api.kartOku('cek-senet', id);
      const kart = k.kart as Record<string, unknown>;
      setKasaAcilis({
        tur,
        tarafId: Number(kart.tarafId) || undefined,
        tarafUnvan: String(k.kodAd?.tarafId?.[String(kart.tarafId)] ?? ''),
        tutar: String(kart.tutar ?? ''),
        cekSenetId: id,
      });
    } catch {
      // Kiymet kaydedildi ama okunamadi: kasa islemi kartini bos acmaktansa
      //   kullaniciyi listeye birak - kiymet portfoyde duruyor.
      setKasaTuru(tur);
    }
  }
  // "Ekstre" modu (A secenegi): ayni grid ekstre kaynagina doner. null = liste.
  const [ekstre, setEkstre] = useState<{ id: number; ad: string } | null>(null);
  // Ekstre dugmesinin aktifligi icin gridden gelen secili satir.
  const [seciliSatir, setSeciliSatir] = useState<ListeSatiri | null>(null);
  // Ekstreden donunce ayni satiri yeniden isaretlemek icin - grid unmount
  //   olurken secim null'a duser, o yuzden SON DOLU deger ayrica saklanir.
  const [sonSeciliId, setSonSeciliId] = useState<number | null>(null);
  // Ekstreden donunce ayni cip (Aktif/Pasif/Tumu) secili kalsin.
  const [cipIndeks, setCipIndeks] = useState(0);

  // RANDEVU TAKVIMI (243) ayarlari: takvim saat araligi/calisma gunleri
  //   Randevu Ayarlari ekranindan (referans) gelir.
  const [randevuAyarlari, setRandevuAyarlari] = useState<{
    baslangicSaat?: string; bitisSaat?: string; slotDk?: number; calismaGunleri?: number[];
  }>({});
  // RANDEVU (251, kullanici: "bu bölüm ve hekimler randevu listesi üst tarafta
  //   tarih sağında listelenip filtrelensin"): tek uctan hem bolum hem hekim
  //   listesi gelir (Randevu Ayarlari > Bölümler ile ayni kaynak).
  const [randevuAgaci, setRandevuAgaci] = useState<RandevuBolumDugumu[]>([]);
  const [bolumSuzgec, setBolumSuzgec] = useState<number | ''>('');
  const [hekimSuzgec, setHekimSuzgec] = useState<number | ''>('');
  useEffect(() => {
    if (tanim.kaynak !== 'randevu') return;
    let iptal = false;
    api.randevuBolumleri()
      .then(y => { if (!iptal) setRandevuAgaci(y) })
      .catch(() => { /* bolum listesi okunamazsa suzgecler bos kalir */ });
    return () => { iptal = true };
  }, [tanim.kaynak]);

  useEffect(() => {
    if (tanim.kaynak !== 'randevu') return;
    let iptal = false;
    api.ayarlar().then(liste => {
      if (iptal) return;
      const bul = (a: string) => liste.find(x => x.anahtar === a)?.deger ?? '';
      const gunler = bul('randevu.calisma_gunleri')
        .split(',').map(x => Number(x.trim())).filter(x => x >= 1 && x <= 7);
      setRandevuAyarlari({
        baslangicSaat: bul('randevu.baslangic_saat') || undefined,
        bitisSaat: bul('randevu.bitis_saat') || undefined,
        slotDk: Number(bul('randevu.slot_dk')) || undefined,
        calismaGunleri: gunler.length ? gunler : undefined,
      });
    }).catch(() => { /* ayar okunamazsa takvim varsayilanla calisir */ });
    return () => { iptal = true };
  }, [tanim.kaynak]);

  /**
   * Randevu suzgecleri (251) gride ve takvime AYNI kosulu verir: ust seritte
   * ne seciliyse alttaki takvim de onu gosterir - iki ayri suzgec kafa karistirir.
   */
  const randevuFiltresi = useMemo<Kosul | undefined>(() => {
    if (tanim.kaynak !== 'randevu') return sabitFiltre;
    const kosullar: Kosul[] = [];
    if (sabitFiltre) kosullar.push(sabitFiltre);
    if (bolumSuzgec !== '') kosullar.push({ alan: 'bolum', op: 'esit', deger: bolumSuzgec });
    if (hekimSuzgec !== '') kosullar.push({ alan: 'hekimId', op: 'esit', deger: hekimSuzgec });
    return kosullar.length === 0 ? undefined
         : kosullar.length === 1 ? kosullar[0]
         : { op: 'and', kosullar };
  }, [tanim.kaynak, sabitFiltre, bolumSuzgec, hekimSuzgec]);

  /**
   * Takvimin kullanacagi ayar: HEKIM -> BÖLÜM -> Genel Ayarlar sirasiyla
   * miras alinir (251). Hekim ogle arasini degistirdiyse takvim o hekim
   * secildiginde onu gostermeli - yoksa bolum duzeni sanilir.
   */
  const takvimAyarlari = useMemo(() => {
    const bolumDugum = bolumSuzgec === '' ? undefined
      : randevuAgaci.find(d => d.departmanId === bolumSuzgec);
    const hekimAyar = hekimSuzgec === ''
      ? undefined
      : (bolumDugum ?? randevuAgaci.find(d => d.hekimler.some(h => h.hekimId === hekimSuzgec)))
          ?.hekimler.find(h => h.hekimId === hekimSuzgec);
    const oncelikli = (...adaylar: (string | number | null | undefined)[]) =>
      adaylar.find(v => v !== '' && v !== null && v !== undefined);
    const gunler = String(oncelikli(hekimAyar?.calismaGunleri, bolumDugum?.ayar.calismaGunleri) ?? '')
      .split(',').map(x => Number(x.trim())).filter(x => x >= 1 && x <= 7);
    return {
      ...randevuAyarlari,
      baslangicSaat: oncelikli(hekimAyar?.baslangicSaat, bolumDugum?.ayar.baslangicSaat) as string
                     ?? randevuAyarlari.baslangicSaat,
      bitisSaat: oncelikli(hekimAyar?.bitisSaat, bolumDugum?.ayar.bitisSaat) as string
                 ?? randevuAyarlari.bitisSaat,
      slotDk: (oncelikli(hekimAyar?.slotDk, bolumDugum?.ayar.slotDk) as number)
              ?? randevuAyarlari.slotDk,
      calismaGunleri: gunler.length ? gunler : randevuAyarlari.calismaGunleri,
    };
  }, [randevuAgaci, randevuAyarlari, bolumSuzgec, hekimSuzgec]);

  /** Bolum secilince hekim listesi o bolume daralir. */
  const hekimSecenekleri = useMemo(() => {
    const dugumler = bolumSuzgec === ''
      ? randevuAgaci
      : randevuAgaci.filter(d => d.departmanId === bolumSuzgec);
    return dugumler.flatMap(d => d.hekimler.map(h => ({ id: h.hekimId ?? 0, ad: h.ad })));
  }, [randevuAgaci, bolumSuzgec]);

  // Aksiyon yonlendirme. Kasa aksiyonlari API cagirir (kesinlestir/iptal/sil) ve
  //   sonrasinda grid'i tazeler; digerleri kart rotasina gider.
  async function aksiyon(kod: string, satir?: ListeSatiri | null,
                         secililer?: ListeSatiri[]) {
    const kartaGit = (kayitId: unknown) => git(`${tanim.kartYolu}/${kayitId}`);

    try {
      // TOPLU ISLEM (183): birden fazla satir seciliyken Hazırla/Gönder tek
      //   istekte calisir. Sonuc satir satir raporlanir - bir belgenin hatasi
      //   digerlerini durdurmaz.
      if (secililer && secililer.length > 1
          && (kod === 'ebelge.hazirla' || kod === 'ebelge.gonder')) {
        const islem = kod === 'ebelge.hazirla' ? 'hazirla' : 'gonder';
        const ad = islem === 'hazirla' ? 'hazırlanacak' : 'GÖNDERİLECEK';
        if (!await onay(`${secililer.length} belge ${ad}.\n\n`
                      + (islem === 'gonder'
                         ? 'Gönderilen belge geri alınamaz. Onaylıyor musunuz?'
                         : 'Her belgeye seri ve e-Belge numarası verilir. Onaylıyor musunuz?'),
                        islem === 'gonder')) return;
        await guvenli(async () => {
          const y = await api.belgeEBelgeToplu(secililer.map(x => Number(x.id)), islem);
          const olan = y.sonuclar.filter(r => r.basarili).length;
          const olmayan = y.sonuclar.filter(r => !r.basarili);
          mesaj(`${olan} belge tamam, ${olmayan.length} hata.`
              + (olmayan.length
                 ? '\n\n' + olmayan.slice(0, 10)
                     .map(r => `#${r.belgeId}: ${r.mesaj}`).join('\n')
                   + (olmayan.length > 10 ? `\n… ve ${olmayan.length - 10} tane daha` : '')
                 : ''));
          setYenile(t => t + 1);
        });
        return;
      }

      // e-BELGE CIKTILARI (Ön İzle / PDF / HTML / XML / Mesaj Geçmişi) ayri
      //   modulde (180 refaktor): hepsi tek belge id'si alip cikti uretiyor,
      //   listeden bagimsiz. Ele aldiysa switch'e hic girmeyiz.
      // GELEN KUTUSU once: oradaki id e_belge kaydidir, belge id'si degil -
      //   ayni "ebelge.*" kodlari farkli uclara gider.
      if (tanim.kaynak === 'gelen-belge'
          && await gelenBelgeAksiyonu(kod, satir ?? null, () => setYenile(t => t + 1),
                                      setEBelgeMesajlari)) return;

      if (satir && await ebelgeCiktisi(kod, satir, setEBelgeMesajlari,
                                       () => setYenile(t => t + 1))) return;

      // DONUSUM ALT MENUSU: "belge.donustur.15" gibi kodlarda hedef tur
      //   kodun icinde gelir ve karta KILITLI gecer.
      if (kod.startsWith('belge.donustur.') && satir) {
        setDonusum({
          belgeId: Number(satir.id),
          belgeTur: Number(satir.tur),
          hedef: Number(kod.slice('belge.donustur.'.length)),
        });
        return;
      }

      switch (kod) {
        // Grup basina bir giris: kart tur seridini o grubun turleriyle acar.
        // Tahsilat/odeme dugmeleri ARAC (nakit/banka/pos/cek/senet) menusu acar;
        //   secilen aracin kodu "kasa.yeni.<tur>" olarak geri gelir ve kart MODAL
        //   olarak acilir (liste arkada kalsin, kullanici listeden kopmasin).
        case 'kasa.tahsilat.yeni': setKasaTuru(21); return;
        case 'kasa.odeme.yeni':    setKasaTuru(31); return;
        case 'kasa.virman.yeni':   setKasaTuru(41); return;
        case 'kasa.doviz.yeni':    setKasaTuru(45); return;
        case 'kasa.plan.yeni':     setKasaTuru(61); return;
        case 'kasa.gerceklestir':
          // Gerceklestirme hesap/tutar secimi ister - plan kartindaki panele goturur.
          if (satir) git(`/kasa-islem/${satir.id}`);
          return;
        case 'kasa.ac':
          // MODAL acilir (kullanici): kart kaydin KENDI turuyle gelir
          //   (tahsilat / odeme / cek / virman...) ve liste arkada kalir -
          //   tam sayfaya gidince kullanici listedeki yerini kaybediyordu.
          if (satir) setAcikKasaId(Number(satir.id));
          return;
        case 'kasa.fis-gor':
          if (satir) git(`/kasa-islem/${satir.id}`);
          return;

        case 'kasa.kesinlestir':
          if (!satir) return;
          if (!await onay('İşlem kesinleştirilecek: makbuz numarası verilir ve muhasebe fişi yazılır. Onaylıyor musunuz?')) return;
          await api.kasaKesinlestir(Number(satir.id));
          setYenile(t => t + 1);
          return;

        case 'kasa.iptal': {
          if (!satir) return;
          const sebep = window.prompt('İptal sebebi:');
          if (!sebep) return;
          await api.kasaIptal(Number(satir.id), sebep);
          setYenile(t => t + 1);
          return;
        }

        case 'kasa.sil':
          if (!satir) return;
          if (!await onay('Taslak/plan kaydı silinecek. Onaylıyor musunuz?')) return;
          await api.kasaSil(Number(satir.id));
          setYenile(t => t + 1);
          return;

        case 'belge.yeni': setYeniBelgeTuru(tanim.yeniBelgeTuru ?? 15); return;
        case 'belge.ac':
          if (satir) setAcikBelgeId(Number(satir.id));
          return;
        // e-BELGE HAZIRLA (163): numara/seri verir ve kuyruga alir. Sonuc
        //   mesaji sunucudan gelir (hangi tur, hangi numara) - istemci karar
        //   uretmez, yalniz gosterir.
        case 'ebelge.hazirla': {
          if (!satir) return;
          const belgeNo = String(satir.belgeNo ?? satir.id);
          if (!await onay(`"${belgeNo}" için e-Belge hazırlansın mı? `
                     + 'Belgeye seri ve e-Belge numarası verilir.')) return;
          await guvenli(async () => {
            const y = await api.belgeEBelgeHazirla(Number(satir.id));
            mesaj((y.uyarilar ?? []).join(' • ') || 'e-Belge hazırlandı.');
            setYenile(t => t + 1);
          });
          return;
        }
        // e-BELGE GONDER: GERI ALINAMAZ, bu yuzden onay metni acik yazilir -
        //   GIB'e giden belge iptal edilmez, yalniz iade faturasiyla duzeltilir.
        case 'ebelge.gonder': {
          if (!satir) return;
          const no = String(satir.belgeNo ?? satir.id);
          await guvenli(async () => {
            // e-ARSIVDE ALICI E-POSTASI SORULUR (184, Delphi ile ayni): alias
            //   alani e-Faturada GIB posta kutusu, e-Arsivde e-posta adresidir.
            //   Bos gonderilirse entegrator belgeyi KAGIT olarak isaretliyor.
            let alias: string | undefined;
            const a = await api.belgeEBelgeAlici(Number(satir.id));
            if (a.belgeTuru === 2) {
              const girilen = await metinSor(
                `"${no}" e-Arşiv olarak gönderilecek.

`
                + 'Belge alıcıya e-postayla iletilir. Boş bırakırsanız kâğıt '
                + 'belge olarak işaretlenir.',
                a.alias || a.onerilenMail, 'Alıcı e-postası');
              if (girilen === null) return;              // vazgecildi
              alias = girilen.trim();
            } else if (!await onay(`"${no}" entegratöre GÖNDERİLECEK.

`
                                 + 'Gönderilen belge geri alınamaz; düzeltme ancak iade '
                                 + 'faturasıyla yapılır. Onaylıyor musunuz?', true)) {
              return;
            }
            const y = await api.belgeEBelgeGonder(Number(satir.id), alias);
            mesaj((y.uyarilar ?? []).join(' • ') || 'Gönderildi.');
            setYenile(t => t + 1);
          });
          return;
        }
        // e-Belge menusunun oteki adimlari (164): seri degistir ve sifirla.
        case 'ebelge.seri': {
          if (!satir) return;
          const seri = prompt('Yeni seri (boş bırakırsanız sıradaki seriye geçilir):', '') ?? undefined;
          await guvenli(async () => {
            const y = await api.belgeEBelgeSeri(Number(satir.id), seri?.trim() || undefined);
            mesaj((y.uyarilar ?? []).join(' • ') || 'Seri değişti.');
            setYenile(t => t + 1);
          });
          return;
        }
        case 'ebelge.sifirla': {
          if (!satir) return;
          if (!await onay('e-Belge geri alınacak; belge yeniden hazırlanabilir hale gelir. '
                     + 'Numara boşa düşer. Onaylıyor musunuz?')) return;
          await guvenli(async () => {
            const y = await api.belgeEBelgeSifirla(Number(satir.id));
            mesaj((y.uyarilar ?? []).join(' • ') || 'e-Belge geri alındı.');
            setYenile(t => t + 1);
          });
          return;
        }
        // e-BELGE IPTALI (188): e-Arsivde dogrudan iptal, e-Faturada GIB'e
        //   iptal TALEBI. Ikisi de geri alinamaz; gerekce zorunlu.
        case 'ebelge.iptal': {
          if (!satir) return;
          const belgeNo = String(satir.belgeNo ?? satir.id);
          if (!await onay(`"${belgeNo}" için e-Belge iptali başlatılacak.

`
                        + 'e-Arşiv doğrudan iptal edilir; e-Faturada GİB’e iptal talebi '
                        + 'gönderilir ve alıcı onayına kalır. Geri alınamaz. Onaylıyor musunuz?',
                          true)) return;
          const gerekce = await metinSor('İptal gerekçesi (zorunlu):', '');
          if (gerekce === null) return;
          if (!gerekce.trim()) { mesaj('İptal gerekçesi zorunlu.'); return }
          await guvenli(async () => {
            const y = await api.belgeEBelgeIptal(Number(satir.id), gerekce);
            mesaj(y.mesaj);
            setYenile(t => t + 1);
          });
          return;
        }
        // MUHASEBE FISI (190): belgenin fis satirlarini acar. Fis kartı ayri
        //   bir ekran degil - "Fiş Satırları" listesi fisId ile filtrelenir.
        case 'belge.fis-gor': {
          if (!satir) return;
          const fisId = Number(satir.fisId ?? 0);
          if (!fisId) { mesaj('Belgenin muhasebe fişi yok.'); return }
          git(`/muhasebe-fis-satir?fisId=${fisId}`);
          return;
        }
        // DONUSUM ZINCIRI (F8): kaynak ve hedef belge ayni modal kartta acilir.
        case 'belge.kaynak-ac':
        case 'belge.hedef-ac': {
          if (!satir) return;
          const hedef = Number(kod === 'belge.kaynak-ac' ? satir.kaynakId : satir.hedefId) || 0;
          if (!hedef) {
            mesaj(kod === 'belge.kaynak-ac'
              ? 'Bu belge bir dönüşümden gelmiyor.'
              : 'Bu belgeden üretilmiş bir belge yok.');
            return;
          }
          setAcikBelgeId(hedef);
          return;
        }
        // BELGE SIL (181): izi olmayan belgede mumkun; kesin/izli belgede
        //   aksiyon zaten pasif ve sebebi title'da. Sunucu son sozu soyler.
        case 'belge.sil': {
          if (!satir) return;
          const no = String(satir.belgeNo ?? satir.id);
          if (!await onay(`"${no}" silinecek.

Bu işlem geri alınamaz. `
                        + 'Onaylıyor musunuz?', true)) return;
          await guvenli(async () => {
            const y = await api.belgeSil(Number(satir.id));
            mesaj(y.mesaj || 'Belge silindi.');
            setYenile(t => t + 1);
          });
          return;
        }
        // CARI MUKELLEFIYET SORGUSU (183): entegratore sorar, bayragi isler.
        //   Gelen unvan/adres YALNIZ GOSTERILIR - musterinin kendi kaydi
        //   entegratorun yazimiyla ezilmemeli.
        case 'cari.ebelge-mukellef': {
          if (!satir) return;
          await guvenli(async () => {
            const y = await api.cariEBelgeMukellef(Number(satir.id));
            const satirlar = [
              String(y.kayitli.unvan || satir.unvan || ''),
              '',
              'GİB kaydı: ' + (y.mukellef
                ? 'e-Fatura MÜKELLEFİ' : 'kayıtlı değil (e-Arşiv kesilir)') + ' — ' + y.durum,
            ];
            if (y.degisti) satirlar.push('Cari kartındaki bayrak güncellendi.');
            // GIB'den gelen unvan/adres YALNIZ GOSTERILIR: musterinin kendi
            //   kaydi entegratorun yazimiyla ezilmemeli.
            if (y.gelen.unvan) {
              satirlar.push('', 'GİB’deki bilgiler:', y.gelen.unvan);
              if (y.gelen.vergiDairesi) satirlar.push(y.gelen.vergiDairesi);
              if (y.gelen.il) satirlar.push(`${y.gelen.adres} ${y.gelen.ilce} / ${y.gelen.il}`);
            }
            mesaj(satirlar.join('\n'));
            setYenile(t => t + 1);
          });
          return;
        }
        case 'belge.donustur':
          if (!satir) return;
          // Teklif (18) yalniz KABUL (3) durumundayken donusur - sunucu da
          //   ayni kurali dogrular, burasi erken/anlasilir uyari.
          if (Number(satir.tur) === 18 && Number(satir.teklifDurum ?? 1) !== 3) {
            mesaj('Teklif yalnız KABUL durumundayken siparişe dönüştürülebilir.');
            return;
          }
          setDonusum({ belgeId: Number(satir.id), belgeTur: Number(satir.tur) });
          return;
        // Secili hesabin ekstresi - ayni ekran, hesapId sorgu parametresiyle.
        case 'hesap.ekstre':
          if (satir) git(`/hesap-ekstre?hesapId=${satir.id}`);
          return;
        // ADAY -> MÜŞTERİ (122): kayit TASINMAZ, yalniz rol bayragi degisir.
        //   Boylece firsat/gorev/adres/ilgili kisi gecmisi ayni kayitta kalir;
        //   yeni bir cari acilsaydi butun bu baglar kirilirdi.
        case 'aday.donustur': {
          if (!satir) return;
          const ad = String(satir.unvan ?? satir.ad ?? satir.id);
          if (!await onay(`"${ad}" müşteriye dönüştürülsün mü?

` +
                       "Kayıt Müşteri Listesi'ne geçer; fırsat, görev ve adres geçmişi aynı kalır.")) return;
          void guvenli(async () => {
            const k = await api.kartOku('cari', Number(satir.id));
            await api.kartGuncelle('cari', Number(satir.id),
              { surum: k.kart.surum as string | undefined,
                kart: { musteri: true, aday: false } });
            setYenile(y => y + 1);
          });
          return;
        }
        // STOK KARTI KOPYALA (126): kopya olusur ve HEMEN acilir - kullanici
        //   zaten degistirmek icin kopyaliyor, listeye donup aramasi gereksiz.
        case 'stok.kopyala': {
          if (!satir) return;
          const ad = String(satir.ad ?? satir.kod ?? satir.id);
          if (!await onay(`"${ad}" kartı kopyalanacak.\n\n`
                     + 'Kod sonuna "_K1", ad sonuna " kopya" eklenir; paket ise içeriği de kopyalanır.\n'
                     + 'Fiyat ve barkod kopyalanmaz.')) return;
          const yeniId = await api.stokKopyala(Number(satir.id));
          setYenile(t => t + 1);
          kartaGit(yeniId);
          return;
        }
        // FIYAT LISTESI URETIMI (202): kurali yeniden isletip satirlari yazar.
        //   Onay ISTENIR - binlerce satiri degistirir ve taban fiyat degistiyse
        //   liste fiyatlari toptan degisir.
        case 'fiyat-listesi.uret': {
          if (!satir) return;
          const ad = String(satir.ad ?? satir.id);
          if (!await onay(`"${ad}" listesinin satırları yeniden üretilecek.

`
                     + 'Kural (taban liste × çarpan → yuvarlama) yeniden işletilir. '
                     + 'Elle girilmiş (Manuel) satırlar KORUNUR.')) return;
          await guvenli(async () => {
            const y = await api.fiyatListesiUret(Number(satir.id));
            mesaj(y.mesaj);
            setYenile(t => t + 1);
          });
          return;
        }
        case 'fiyat-listesi.satirlar':
          if (satir) git(`/fiyat-listesi-satir?listeId=${satir.id}`);
          return;

        // EXCEL AKISI (207): modal sablon indirme + yukleme + hata tablosunu tasir.
        case 'fiyat-listesi.iceri-al':
          if (satir) setIceriAl({ listeId: Number(satir.id), ad: String(satir.ad ?? satir.id) });
          return;
        case 'fiyat-listesi.sablon':
          if (!satir) return;
          await guvenli(async () =>
            dosyaIndirUrl(await api.fiyatListesiSablon(Number(satir.id), true),
                          `${String(satir.ad ?? satir.id)}.xlsx`, true));
          return;

        // ÜTS (223): senkron + alma + iptal + yeniden gonder + detay.
        case 'belge.uts-bildir': {
          // COKLU SECIM desteklenir (230): isaretli belgeler sirayla bildirilir.
          const hedefler = (secililer && secililer.length > 0 ? secililer
                            : satir ? [satir] : []);
          if (hedefler.length === 0) return;
          const adlar = hedefler.length === 1
            ? `"${String(hedefler[0].belgeNo ?? hedefler[0].id)}" belgesinin`
            : `${hedefler.length} belgenin`;
          if (!await onay(`${adlar} seri/lot satırları ÜTS'ye bildirilecek.

Satışta VERME, alışta askıdakilerle eşleşip ALMA yapılır. Onaylıyor musunuz?`)) return;
          await guvenli(async () => {
            let son: Awaited<ReturnType<typeof api.utsBelgedenBildir>> | null = null;
            const ozet: string[] = [];
            for (const h of hedefler) {
              son = await api.utsBelgedenBildir(Number(h.id));
              ozet.push(son.mesaj);
            }
            if (hedefler.length === 1 && son) setUtsBelgeSonuc(son);
            else mesaj(ozet.join('\n'));
            setYenile(t => t + 1);
          });
          return;
        }
        // Iki asamali verme (kullanici): 1) hazirla - e-Belgeli satis
        //   faturalarindan BEKLEYEN kayitlar gride dolar (UTS'ye gitmez),
        //   2) gridde secilenler "📤 Gönder" ile cikar.
        case 'uts.verme':
          await guvenli(async () => {
            const y = await api.utsVermeHazirla();
            // Atlananlar GRIDDE (kullanici): siralanir + CSV kaydedilir.
            if (y.atlanan.length > 0) setUtsHazirla(y); else mesaj(y.mesaj);
            setYenile(t => t + 1);
          });
          return;
        case 'uts.kullanim': setUtsKullanim(true); return;
        case 'uts.uretim':   setUtsGenel('uretim'); return;
        case 'uts.ithalat':  setUtsGenel('ithalat'); return;
        case 'uts.hek':      setUtsGenel('hek'); return;
        case 'uts.imha':     setUtsGenel('imha'); return;
        case 'uts.senkron':
          await guvenli(async () => {
            const y = await api.utsAskidakilerSenkron();
            mesaj(y.mesaj);
            setYenile(t => t + 1);
          });
          return;
        case 'uts.al':
          if (!satir) return;
          if (Number(satir.durum) !== 1) { mesaj('Bu kayıt askıda değil.'); return }
          setUtsAlma({
            envanterId: Number(satir.id),
            urunNo: String(satir.urunNo ?? ''),
            kurumUnvan: String(satir.kurumUnvan ?? ''),
            askiAdet: Number(satir.askiAdet ?? 1),
            seriNo: String(satir.seriNo ?? ''),
          });
          return;
        case 'uts.iptal': {
          if (!satir) return;
          if (Number(satir.tur) === 1) {
            mesaj("Alma bildirimi ÜTS'de iptal edilemez (karşı taraf verme bildirimini iptal etmelidir).");
            return;
          }
          if (!await onay(`"${String(satir.utsBildirimId ?? satir.id)}" bildirimi ÜTS'de İPTAL edilecek.

Onaylıyor musunuz?`)) return;
          await guvenli(async () => {
            const y = await api.utsIptal(Number(satir.id));
            mesaj(y.mesaj);
            setYenile(t => t + 1);
          });
          return;
        }
        case 'uts.yeniden-gonder': {
          // GONDER: coklu secim - isaretli bekleyen/hatali bildirimler
          //   sirayla UTS'ye cikar, satirlar guncellenir.
          const hedefler = (secililer && secililer.length > 0 ? secililer
                            : satir ? [satir] : []);
          if (hedefler.length === 0) return;
          if (!await onay(`${hedefler.length} bildirim ÜTS'ye GÖNDERİLECEK.

Gönderilen bildirim resmî işlemdir. Onaylıyor musunuz?`, true)) return;
          await guvenli(async () => {
            let tamam = 0; const hatalar: string[] = [];
            for (const h of hedefler) {
              try {
                const y = await api.utsYenidenGonder(Number(h.id));
                if (y.basarili) tamam++;
                else hatalar.push(`#${h.id}: ${y.mesaj}`);
              } catch (hh) {
                hatalar.push(`#${h.id}: ${hataMetni(hh)}`);
              }
            }
            mesaj(hedefler.length === 1 && hatalar.length === 0
              ? 'Bildirim başarıyla gönderildi.'
              : `${tamam}/${hedefler.length} bildirim gönderildi.`
                + (hatalar.length > 0 ? '\n\n' + hatalar.join('\n') : ''));
            setYenile(t => t + 1);
          });
          return;
        }
        case 'uts.detay':
          if (!satir) return;
          await guvenli(async () => {
            const y = await api.utsBildirimDetay(Number(satir.id));
            const ozet = y.mesajlar.map(m => `${m.tip ?? ''}: ${m.met ?? ''}`).join('\n');
            mesaj(y.sonuc != null
              ? JSON.stringify(y.sonuc, null, 2).slice(0, 1500)
              : (ozet || 'ÜTS detay dönmedi.'));
          });
          return;

        case 'genel.yazdir': mesaj('Yazdirma henuz baglanmadi.'); return;
      }

      // Alt menuden gelen arac secimi: "kasa.yeni.22" -> tur 22 ile modal.
      if (kod.startsWith('kasa.yeni.')) {
        const t = Number(kod.slice(10));
        // CEK / SENET (23/24/33/34): once KIYMET KARTI acilir (kullanici) -
        //   banka, sube, kesideci, seri no, vade... kasa kartinda sorulamayacak
        //   kadar cok alan var. Kart kaydedilince kasa islemi o kiymete
        //   BAGLANARAK olusturulur (asagida cekKartKaydedildi).
        if (t === 23 || t === 24 || t === 33 || t === 34) { setCekTuru(t); return }
        setKasaTuru(t);
        return;
      }

      if (kod.endsWith('.yeni') && tanim.kartYolu) git(`${tanim.kartYolu}/yeni`);
      // SIL gercekten SILER: eskiden karti aciyordu ve kullanici "sildim" sanip
      //   ekranda kaydi gorunce sasiriyordu. Onay sorulur; silme engelleri
      //   (SilmeEngeli) sunucuda, 422 mesaji kullaniciya aynen gosterilir.
      else if (kod.endsWith('.sil') && satir && tanim.kartYolu) {
        const ad = String(satir.ad ?? satir.konu ?? satir.unvan ?? satir.kod ?? satir.id);
        if (!await onay(`"${ad}" silinecek. Onaylıyor musunuz?`)) return;
        // Kart adi KAYNAK'tir, rota degil: Cek/Senet listelerinin rotasi '/cek'
        //   ama kart 'cek-senet'. Yoldan turetmek yanlis karta giderdi.
        await api.kartSil(tanim.kaynak, Number(satir.id));
        setYenile(t => t + 1);
      }
      else if ((kod.endsWith('.duzenle') || kod.endsWith('.ac')) && satir && tanim.kartYolu)
        kartaGit(satir.id);
      else if (satir) mesaj(`"${kod}" aksiyonu henuz baglanmadi.`);
    } catch (h) {
      mesaj(hataMetni(h));
    }
  }

  return (
    <>
    {/* EKSTRE MODU (A): grid ekstre kaynagina doner. Ust cip seridinden
        Aktif/Pasif/Tumu'ye basmak listeye geri getirir. */}
    {ekstre && tanim.ekstre ? (
      <GenGrid
        key={`${tanim.ekstre.kaynak}-${ekstre.id}`}
        kaynak={tanim.ekstre.kaynak}
        baslik={`${c(tanim.ekstre.baslik)} — ${ekstre.ad}`}
        yol={yolCevir(tanim.yol)}
        sabitFiltre={{ alan: tanim.ekstre.alan, op: 'esit', deger: ekstre.id }}
        // DOVIZSIZ ekstrede yerel karsilik kolonlari CIZILMEZ (kullanici):
        //   hepsi TL ise "Borç" ile "Yerel Borç" ayni sayiyi iki kez gosterir.
        //   Kur kolonu da ayni sebeple gizlenir (her satirda 1).
        dovizsizGizle={['dovizKuru', 'yerelBorc', 'yerelAlacak', 'yerelBakiye']}
        // Cari ekstresinde kolonlar borc/alacak, hesap ekstresinde giris/cikis;
        //   ikisinin de yerel karsiligi toplanir (genel toplam yerel parada).
        toplam={tanim.ekstre.kaynak === 'cari-ekstre'
          ? ['borc', 'alacak', 'yerelBorc', 'yerelAlacak']
          : ['giris', 'cikis', 'yerelBorc', 'yerelAlacak']}
        // Cipler ekstre modunda YALNIZ "geri don" gorevi gorur: filtreleri
        //   birlikte gondermek ekstre kaynagina "Bilinmeyen alan: durum" 400'u
        //   verdiriyordu (ekstre goruntusunde durum kolonu yok).
        cipler={tanim.cipler?.map(c => ({ ad: c.ad }))}
        tarihAlani={tanim.ekstre.tarihAlani}
        tarihVarsayilan="yilbasindanBugune"
        // Ekstrede yalniz cikti aksiyonlari (Yazdir ▾ = CSV Kaydet / Yazdir);
        //   Ekle/Duzenle/Sil hesap listesine ait.
        aksiyonEkrani="cikti-liste"
        // Cift tik: satiri URETEN kayda git - once kasa islemi, yoksa belge.
        onSatirAc={satir => {
          const kasaId = Number(satir.kasaIslemId ?? 0);
          const belgeId = Number(satir.belgeId ?? 0);
          if (kasaId) setAcikKasaId(kasaId);
          else if (belgeId) setAcikBelgeId(belgeId);
        }}
        onAksiyon={kod => { if (kod === 'genel.yazdir') mesaj('Yazdirma henuz baglanmadi.') }}
        cipBaslangic={cipIndeks}
        // Cip'e basmak = listeye don (secilen filtreyle).
        onCipSecildi={i => { setCipIndeks(i); setEkstre(null) }}
        cipSonu={
          <button className="on" disabled title="Ekstre gösteriliyor">
            📄 {ekstre.ad}
          </button>
        }
      />
    ) : (
    <>
    <GenGrid
      // key: kaynak degisince (baska liste ekranina gecince) GenGrid TAMAMEN yeniden
      //   kurulsun - Route ayni tree konumunda kaldigi icin React bilesen orneğini
      //   REUSE ediyordu, onceki ekranin state'i (aramaGorunumu, sirala, arama, sayfa...)
      //   yeni ekrana sizip yanlis/bos sonuc gosteriyordu (ör. Cari'de "Son Aranan"
      //   secilince Islem Gunlugu'ne gecince orada da "son" gonderiliyordu).
      key={tanim.rota ?? tanim.kaynak}
      kaynak={tanim.kaynak}
      baslik={cm(tanim.baslik)}
      yol={tanim.yol}
      toplam={tanim.toplam}
      cipler={tanim.cipler}
      sabitFiltre={randevuFiltresi}
      aksiyonEkrani={tanim.aksiyonEkrani}
      ebelgeMenusu={tanim.ebelgeMenusu}
      gizliKolonlar={tanim.gizliKolonlar}
      aramaGorunumGizli={tanim.aramaGorunumGizli}
      kolonSirasi={tanim.kolonSirasi}
      altSecenekler={{ ...KASA_ARAC_MENUSU, ...DONUSUM_MENUSU,
                       ...(tanim.altSecenekler ?? {}) }}
      yenile={yenile}
      odaklaSonEklenen={odaklaSonEklenen}
      icerikAlani={tanim.icerikAlani}
      icerikBaslik={tanim.icerikBaslik}
      onSatirAc={satir => {
        // Belge listelerinde kart MODAL acilir (rota yok); digerlerinde kartYolu.
        if (tanim.kaynak === 'belge' || tanim.kaynak === 'irsaliye'
            || tanim.kaynak === 'stok-transfer' || tanim.kaynak === 'stok-talep'
            || tanim.kaynak === 'giris-fis' || tanim.kaynak === 'cikis-fis')
          setAcikBelgeId(Number(satir.id));
        // Kasa islemi de MODAL (kullanici) - "Aç" aksiyonuyla ayni davranis.
        else if (tanim.kaynak === 'kasa-islem') setAcikKasaId(Number(satir.id));
        // Gelen belgenin KARTI YOK: cift tik gonderenin goruntusunu acar.
        else if (tanim.kaynak === 'gelen-belge')
          void gelenBelgeAksiyonu('gelen.goruntule', satir, () => setYenile(t => t + 1));
        else if (tanim.kartYolu) git(`${tanim.kartYolu}/${satir.id}`);
      }}
      onAksiyon={(kod, satir, secililer) => { void aksiyon(kod, satir, secililer) }}
      tarihAlani={tanim.tarihAlani}
      // Ekstreden donunce ayni hesap secili kalsin.
      seciliBaslangicId={sonSeciliId}
      cipBaslangic={cipIndeks}
      onCipSecildi={setCipIndeks}
      onCipRota={r => git(`/${r}`)}
      onSecimDegisti={s => { setSeciliSatir(s); if (s) setSonSeciliId(Number(s.id)) }}
      cipSonu={tanim.kaynak === 'randevu' ? (
        // Bolum/hekim suzgeci TARIH ARALIGININ SAGINDA (kullanici) - grid ve
        //   altindaki takvim ayni secimi kullanir.
        <>
          <select value={bolumSuzgec} title="Bölüm"
                  onChange={e => { setBolumSuzgec(e.target.value ? Number(e.target.value) : '');
                                   setHekimSuzgec('') }}>
            <option value="">Tüm bölümler</option>
            {randevuAgaci.map(d => (
              <option key={d.departmanId} value={d.departmanId}>{d.ad}</option>
            ))}
          </select>
          <select value={hekimSuzgec} title="Hekim"
                  onChange={e => setHekimSuzgec(e.target.value ? Number(e.target.value) : '')}>
            <option value="">Tüm hekimler</option>
            {hekimSecenekleri.map(h => <option key={h.id} value={h.id}>{h.ad}</option>)}
          </select>
          {(bolumSuzgec !== '' || hekimSuzgec !== '') && (
            <button type="button" title="Bölüm/hekim filtresini kaldır"
                    onClick={() => { setBolumSuzgec(''); setHekimSuzgec('') }}>×</button>
          )}
        </>
      ) : tanim.ekstre && (
        <button
          disabled={!seciliSatir}
          title={seciliSatir ? 'Seçili hesabın ekstresi' : 'Önce bir satır seçin'}
          onClick={() => seciliSatir && setEkstre({
            id: Number(seciliSatir.id),
            ad: String(seciliSatir.ad ?? seciliSatir.unvan ?? seciliSatir.id),
          })}
        >
          📄 Ekstre
        </button>
      )}
      // RANDEVU (243): takvim gridin ALTINDA ama AYNI kaydirma alaninda -
      //   disarida kardes olunca .sahne (flex:1) eziliyor, cip seridi ve grid
      //   kirpiliyordu. Hucre tiklamasi o saate yeni randevu acar.
      altPanel={tanim.kaynak === 'randevu' && (
        <RandevuTakvimi
          ayarlar={takvimAyarlari}
          bolum={bolumSuzgec === '' ? undefined : bolumSuzgec}
          hekimId={hekimSuzgec === '' ? undefined : hekimSuzgec}
          yenile={yenile}
          onYeni={bas => git(`/randevu/yeni?baslangic=${encodeURIComponent(bas)}`)}
          onAc={id => git(`/randevu/${id}`)}
        />
      )}
    />
    </>
    )}

    {acikKasaId !== null && (
      <KasaIslemKarti
        kayitIdProp={acikKasaId}
        onKapat={() => { setAcikKasaId(null); setYenile(t => t + 1) }}
      />
    )}

    {/* CEK/SENET: kiymet karti. Kaydedilince ayni bilgilerle kasa islemi
        (23/24/33/34) acilir ve kiymete baglanir - cari o anda alacaklanir /
        borclanir, kagit portfoye girer. */}
    {cekTuru !== null && (
      <GenForm
        kaynak="cek-senet"
        id="yeni"
        baslik={cekTuru === 24 || cekTuru === 34 ? 'Senet' : 'Çek'}
        yeniKayitVarsayilanlari={{
          tur: cekTuru === 24 || cekTuru === 34 ? 2 : 1,
          yon: cekTuru === 33 || cekTuru === 34 ? 2 : 1,
        }}
        onKapat={() => setCekTuru(null)}
        onKaydedildi={id => { void cekKartKaydedildi(cekTuru, id) }}
      />
    )}

    {kasaTuru !== null && (
      <KasaIslemKarti
        acilis={{ tur: kasaTuru }}
        onKapat={() => { setKasaTuru(null); setYenile(t => t + 1) }}
      />
    )}

    {kasaAcilis !== null && (
      <KasaIslemKarti
        acilis={kasaAcilis}
        onKapat={() => { setKasaAcilis(null); setYenile(t => t + 1) }}
      />
    )}

    {acikBelgeId !== null && (
      <BelgeKarti id={acikBelgeId} onKapat={() => setAcikBelgeId(null)} />
    )}

    {yeniBelgeTuru !== null && (
      <BelgeKarti
        tur={yeniBelgeTuru}
        onKapat={() => setYeniBelgeTuru(null)}
        onKaydedildi={() => setYenile(t => t + 1)}
      />
    )}

    {/* MESAJ GECMISI (178): belgenin e-Belge yolculugu - hazirlama, gonderim
        denemeleri ve GIB yanitlari tek pencerede. */}
    {eBelgeMesajlari && (
      <Modal
        baslik={`e-Belge Mesaj Geçmişi — ${eBelgeMesajlari.belgeNo}`}
        onKapat={() => setEBelgeMesajlari(null)}
        alt={<button className="d kapat-dugmesi"
                     onClick={() => setEBelgeMesajlari(null)}>Kapat</button>}
      >
        <div className="kagrup">
          {eBelgeMesajlari.satirlar.length === 0 ? (
            <div className="not" style={{ padding: 10 }}>
              Bu belge için henüz e-Belge işlemi yapılmamış.
            </div>
          ) : (
            <table className="grid">
              <thead>
                <tr><th style={{ width: 40 }}>#</th><th style={{ width: 140 }}>Tarih</th>
                    <th>Olay</th><th>Durum</th><th style={{ width: 90 }}>Kod</th>
                    <th>Açıklama</th></tr>
              </thead>
              <tbody>
                {eBelgeMesajlari.satirlar.map(m => (
                  <tr key={m.sira}>
                    <td>{m.sira}</td>
                    <td>{m.tarih ? new Date(m.tarih).toLocaleString('tr-TR') : '—'}</td>
                    <td>{m.olay}</td>
                    <td>{m.durum}</td>
                    <td>{m.kod}</td>
                    <td>{m.aciklama}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </Modal>
    )}

    {iceriAl && (
      <IceriAlModali
        baslik={iceriAl.ad}
        sablonIndir={(dolu: boolean) => api.fiyatListesiSablon(iceriAl.listeId, dolu)}
        yukle={(dosya: File) => api.fiyatListesiIceriAl(iceriAl.listeId, dosya)}
        onKapat={() => setIceriAl(null)}
        onAlindi={() => setYenile(t => t + 1)}
      />
    )}
    {utsBelgeSonuc && (
      <UtsBelgeSonucModali sonuc={utsBelgeSonuc} onKapat={() => setUtsBelgeSonuc(null)} />
    )}
    {utsHazirla && (
      <UtsHazirlaSonucModali sonuc={utsHazirla} onKapat={() => setUtsHazirla(null)} />
    )}
    {utsGenel && (
      <UtsGenelBildirimModali
        tur={utsGenel}
        onKapat={() => setUtsGenel(null)}
        onTamam={m => { setUtsGenel(null); mesaj(m); setYenile(t => t + 1) }}
      />
    )}
    {utsKullanim && (
      <UtsKullanimModali
        onKapat={() => setUtsKullanim(false)}
        onTamam={m => { setUtsKullanim(false); mesaj(m); setYenile(t => t + 1) }}
      />
    )}
    {utsAlma && (
      <UtsAlmaModali
        envanterId={utsAlma.envanterId}
        urunNo={utsAlma.urunNo}
        kurumUnvan={utsAlma.kurumUnvan}
        askiAdet={utsAlma.askiAdet}
        seriNo={utsAlma.seriNo}
        onKapat={() => setUtsAlma(null)}
        onTamam={m => { setUtsAlma(null); mesaj(m); setYenile(t => t + 1) }}
      />
    )}
    {donusum && (
      <BelgeDonusumModali
        belgeId={donusum.belgeId}
        belgeTur={donusum.belgeTur}
        varsayilanHedef={donusum.hedef}
        // Hedef LISTEDE secildiyse kartta degistirilemez (kullanici): karar
        //   zaten verilmis, ikinci kez sormak hata kapisi acar.
        hedefKilitli={donusum.hedef != null}
        onKapat={() => setDonusum(null)}
        // Modal KAPANMAZ: sonucu (yeni belge no + tutar) kendi icinde gosterir.
        //   mesaj() kullanmak tarayici diyalogu acar ve sayfayi kilitler.
        onTamam={() => setYenile(t => t + 1)}
      />
    )}

    {kartId !== null && tanim.kartYolu && !tanim.ozelKart && (
      <GenForm
        kaynak={tanim.kaynak}
        id={kartId}
        baslik={tanim.baslik.replace(/ler$|lar$/, '')}
        yerTutucuSekmeler={tanim.yerTutucuSekmeler}
        gizliAlanlar={tanim.gizliKartAlanlari}
        gizliSekmeler={tanim.gizliKartSekmeleri}
        zorunluAlanlar={tanim.zorunluKartAlanlari}
        resimYerTutucu={tanim.resimYerTutucu}
        yeniKayitVarsayilanlari={tanim.yeniKayitVarsayilanlari}
        onKapat={() => git(tanim.kartYolu!)}
        onKaydedildi={yeniId => {
          setYenile(t => t + 1);
          if (kartId === 'yeni') {
            setOdaklaSonEklenen(t => t + 1);
            git(`${tanim.kartYolu}/${yeniId}`, { replace: true });
          }
        }}
      />
    )}
    </>
  );
}
