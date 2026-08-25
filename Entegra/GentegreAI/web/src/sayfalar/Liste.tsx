import { useMemo, useState } from 'react';
import { useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { GenGrid } from '../bilesenler/GenGrid';
import { GenForm } from '../bilesenler/GenForm';
import { ApiHatasi, type Kosul, type ListeSatiri } from '../api/sozlesme';
import { api } from '../api/istemci';
import { BelgeDonusumModali } from '../bilesenler/BelgeDonusumModali';
import { BelgeKarti } from './BelgeKarti';
import { KasaIslemKarti } from './KasaIslemKarti';
import { KASA_ARAC_MENUSU, LISTELER, type ListeTanimi } from './listeTanimlari';

// Tanimlar ayri dosyada (listeTanimlari); disaridan alisilmis yol bozulmasin
//   diye buradan da disa aktarilir (App.tsx / Kabuk.tsx LISTELER'i buradan alir).
export { LISTELER };
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
  // Donusum modali (F8): siparis/irsaliye satirlarindan yeni belge uretir.
  const [donusum, setDonusum] = useState<{ belgeId: number; belgeTur: number } | null>(null);
  // Belge (fatura/siparis) karti da MODAL: liste arkada kalir, rota degismez.
  const [yeniBelgeTuru, setYeniBelgeTuru] = useState<number | null>(null);
  // Mevcut belgeyi ac (salt gorunum) - ayni modal, id ile.
  const [acikBelgeId, setAcikBelgeId] = useState<number | null>(null);
  // Kasa islem karti MODAL (tahsilat/odeme): liste arkada acik kalir.
  const [kasaTuru, setKasaTuru] = useState<number | null>(null);
  // Ekstre satirindan acilan MEVCUT kasa islemi (salt gorunum/duzenleme).
  const [acikKasaId, setAcikKasaId] = useState<number | null>(null);
  // "Ekstre" modu (A secenegi): ayni grid ekstre kaynagina doner. null = liste.
  const [ekstre, setEkstre] = useState<{ id: number; ad: string } | null>(null);
  // Ekstre dugmesinin aktifligi icin gridden gelen secili satir.
  const [seciliSatir, setSeciliSatir] = useState<ListeSatiri | null>(null);
  // Ekstreden donunce ayni satiri yeniden isaretlemek icin - grid unmount
  //   olurken secim null'a duser, o yuzden SON DOLU deger ayrica saklanir.
  const [sonSeciliId, setSonSeciliId] = useState<number | null>(null);
  // Ekstreden donunce ayni cip (Aktif/Pasif/Tumu) secili kalsin.
  const [cipIndeks, setCipIndeks] = useState(0);

  // Aksiyon yonlendirme. Kasa aksiyonlari API cagirir (kesinlestir/iptal/sil) ve
  //   sonrasinda grid'i tazeler; digerleri kart rotasina gider.
  async function aksiyon(kod: string, satir?: ListeSatiri | null) {
    const kartaGit = (kayitId: unknown) => git(`${tanim.kartYolu}/${kayitId}`);

    try {
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
        case 'kasa.fis-gor':
          if (satir) git(`/kasa-islem/${satir.id}`);
          return;

        case 'kasa.kesinlestir':
          if (!satir) return;
          if (!confirm('İşlem kesinleştirilecek: makbuz numarası verilir ve muhasebe fişi yazılır. Onaylıyor musunuz?')) return;
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
          if (!confirm('Taslak/plan kaydı silinecek. Onaylıyor musunuz?')) return;
          await api.kasaSil(Number(satir.id));
          setYenile(t => t + 1);
          return;

        case 'belge.yeni': setYeniBelgeTuru(tanim.yeniBelgeTuru ?? 15); return;
        case 'belge.ac':
          if (satir) setAcikBelgeId(Number(satir.id));
          return;
        case 'belge.donustur':
          if (!satir) return;
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
          if (!confirm(`"${ad}" müşteriye dönüştürülsün mü?

` +
                       "Kayıt Müşteri Listesi'ne geçer; fırsat, görev ve adres geçmişi aynı kalır.")) return;
          void (async () => {
            try {
              const k = await api.kartOku('cari', Number(satir.id));
              await api.kartGuncelle('cari', Number(satir.id),
                { surum: k.kart.surum as string | undefined,
                  kart: { musteri: true, aday: false } });
              setYenile(y => y + 1);
            } catch (h) {
              alert(h instanceof ApiHatasi ? h.message : String(h));
            }
          })();
          return;
        }
        // STOK KARTI KOPYALA (126): kopya olusur ve HEMEN acilir - kullanici
        //   zaten degistirmek icin kopyaliyor, listeye donup aramasi gereksiz.
        case 'stok.kopyala': {
          if (!satir) return;
          const ad = String(satir.ad ?? satir.kod ?? satir.id);
          if (!confirm(`"${ad}" kartı kopyalanacak.\n\n`
                     + 'Kod sonuna "_K1", ad sonuna " kopya" eklenir; paket ise içeriği de kopyalanır.\n'
                     + 'Fiyat ve barkod kopyalanmaz.')) return;
          const yeniId = await api.stokKopyala(Number(satir.id));
          setYenile(t => t + 1);
          kartaGit(yeniId);
          return;
        }
        case 'genel.yazdir': alert('Yazdirma henuz baglanmadi.'); return;
      }

      // Alt menuden gelen arac secimi: "kasa.yeni.22" -> tur 22 ile modal.
      if (kod.startsWith('kasa.yeni.')) { setKasaTuru(Number(kod.slice(10))); return }

      if (kod.endsWith('.yeni') && tanim.kartYolu) git(`${tanim.kartYolu}/yeni`);
      // SIL gercekten SILER: eskiden karti aciyordu ve kullanici "sildim" sanip
      //   ekranda kaydi gorunce sasiriyordu. Onay sorulur; silme engelleri
      //   (SilmeEngeli) sunucuda, 422 mesaji kullaniciya aynen gosterilir.
      else if (kod.endsWith('.sil') && satir && tanim.kartYolu) {
        const ad = String(satir.ad ?? satir.konu ?? satir.unvan ?? satir.kod ?? satir.id);
        if (!confirm(`"${ad}" silinecek. Onaylıyor musunuz?`)) return;
        // Kart adi KAYNAK'tir, rota degil: Cek/Senet listelerinin rotasi '/cek'
        //   ama kart 'cek-senet'. Yoldan turetmek yanlis karta giderdi.
        await api.kartSil(tanim.kaynak, Number(satir.id));
        setYenile(t => t + 1);
      }
      else if ((kod.endsWith('.duzenle') || kod.endsWith('.ac')) && satir && tanim.kartYolu)
        kartaGit(satir.id);
      else if (satir) alert(`"${kod}" aksiyonu henuz baglanmadi.`);
    } catch (h) {
      alert(h instanceof ApiHatasi ? h.message : String(h));
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
        baslik={`${tanim.ekstre.baslik} — ${ekstre.ad}`}
        yol={tanim.yol}
        sabitFiltre={{ alan: tanim.ekstre.alan, op: 'esit', deger: ekstre.id }}
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
        onAksiyon={kod => { if (kod === 'genel.yazdir') alert('Yazdirma henuz baglanmadi.') }}
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
    <GenGrid
      // key: kaynak degisince (baska liste ekranina gecince) GenGrid TAMAMEN yeniden
      //   kurulsun - Route ayni tree konumunda kaldigi icin React bilesen orneğini
      //   REUSE ediyordu, onceki ekranin state'i (aramaGorunumu, sirala, arama, sayfa...)
      //   yeni ekrana sizip yanlis/bos sonuc gosteriyordu (ör. Cari'de "Son Aranan"
      //   secilince Islem Gunlugu'ne gecince orada da "son" gonderiliyordu).
      key={tanim.rota ?? tanim.kaynak}
      kaynak={tanim.kaynak}
      baslik={tanim.baslik}
      yol={tanim.yol}
      toplam={tanim.toplam}
      cipler={tanim.cipler}
      sabitFiltre={sabitFiltre}
      aksiyonEkrani={tanim.aksiyonEkrani}
      gizliKolonlar={tanim.gizliKolonlar}
      kolonSirasi={tanim.kolonSirasi}
      altSecenekler={KASA_ARAC_MENUSU}
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
        else if (tanim.kartYolu) git(`${tanim.kartYolu}/${satir.id}`);
      }}
      onAksiyon={(kod, satir) => { void aksiyon(kod, satir) }}
      tarihAlani={tanim.tarihAlani}
      // Ekstreden donunce ayni hesap secili kalsin.
      seciliBaslangicId={sonSeciliId}
      cipBaslangic={cipIndeks}
      onCipSecildi={setCipIndeks}
      onSecimDegisti={s => { setSeciliSatir(s); if (s) setSonSeciliId(Number(s.id)) }}
      cipSonu={tanim.ekstre && (
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
    />
    )}

    {acikKasaId !== null && (
      <KasaIslemKarti
        kayitIdProp={acikKasaId}
        onKapat={() => setAcikKasaId(null)}
      />
    )}

    {kasaTuru !== null && (
      <KasaIslemKarti
        acilis={{ tur: kasaTuru }}
        onKapat={() => { setKasaTuru(null); setYenile(t => t + 1) }}
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

    {donusum && (
      <BelgeDonusumModali
        belgeId={donusum.belgeId}
        belgeTur={donusum.belgeTur}
        onKapat={() => setDonusum(null)}
        // Modal KAPANMAZ: sonucu (yeni belge no + tutar) kendi icinde gosterir.
        //   alert() kullanmak tarayici diyalogu acar ve sayfayi kilitler.
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
