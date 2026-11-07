import { useCallback, useContext, useEffect, useMemo, useRef, useState } from 'react';
import { useLocation, useParams, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni, type ListeSatiri } from '../../api/sozlesme';
import {
  type FisIzlem, type FisKontrolu, type FisOperasyonu, type FisSatiri, type FisGrup, type FisIstegi,
  type FisYaniti, type MamulBilgisi, fisDurumAdi, fisMaliyeti, fisSatirlariniOranla,
} from '../../api/uclar/uretimFisi';
import { DokumanGalerisi } from '../../bilesenler/DokumanGalerisi';
import { IzlemPenceresi } from '../../bilesenler/belge/IzlemPenceresi';
import { StokAramaPenceresi } from '../../bilesenler/StokAramaPenceresi';
import { useSekmedeAc } from '../../bilesenler/KartAdi';
import { mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import { tarihSaat, yerelAnMetni } from '../../bilesenler/bicim';
import { EkranSekmesiBaglami, LISTE_TAZELE_OLAYI } from '../../bilesenler/sekmeBaglami';
import { useKartKapat } from '../../bilesenler/useKartKapat';
import { useUretimSeviyesi } from '../../bilesenler/useUretimSeviyesi';
import { useOturum } from '../../kimlik/OturumBaglami';
import { c } from '../../dil/ceviri';
import type { IzlemSatiri } from '../belgeSatir';
import { GRUP_AD, VARSAYILAN_KONTROLLER, anGirdi, bosSatir, eksikMi, enCokUretilir, izlemeAd, mk, satirTutar, tl } from './uretimFisiYardimci';
import { DenetimIziPaneli, FisSerbestPenceresi, IzlenebilirlikPaneli, MaliyetPaneli } from './UretimFisiPanelleri';
import { UF_STILI } from './uretimStil';

/**
 * ÜRETİM FİŞİ KARTI (1253) - mockuplar Ekranlar/Uretim/uretim_fisi.html (v1), uretim_fisi_v2.html (denetimli),
 * uretim_basit.html ① (basit). Kullanıcı 03.11.2026: "basit / karmaşık planlama yaptığın üretim emri ve üretim fişini
 * mockuplara uygun uygula".
 *
 * TEK EKRAN, ÜÇ SEVİYE: ekran ve kayıt yapısı aynı; `useUretimSeviyesi` neyin görüneceğini söyler.
 *  - Basit: mamul + miktar, malzemeler ağaçtan; lot kolonu yalnız izlemli stokta; fire TEK alan, işçilik TEK tutar; giriş
 *    deposu gizli (bağlantıyla açılır); Kaydet = kaydet + stoğa işle. Sil = ters kayıt.
 *  - Standart: lot kolonu, ＋ Gider / ＋ Fire / ＋ Yan ürün, normal / anormal fire, plan / sapma, Maliyet ve Operasyon
 *    sekmeleri, Son maliyet / Ortalama seçimi; Kaydet taslak, Gerçekleştir ayrı.
 *  - Denetimli: durum adımları, gerçekleşen çıktı KARANTİNADA, Kalite (kontrol listesi + parolalı serbest bırakma),
 *    İzlenebilirlik ve Denetim İzi sekmeleri; Sil yerine gerekçeli Ters Kayıt.
 *
 * Maliyet SUNUCUDA hesaplanır (gerçekleştirme); karttaki özet aynı formülün ÖNİZLEMESİDİR (fisMaliyeti) - kaydetmeden önce
 * aynı rakam görünsün. Birim maliyeti bilinmeyen (elle eklenen) satır 0 ile gelir, kayıtta yöntemden okunur.
 * Kaydet / Sil / Ters Kayıt sonrası sekme kapanır (genel kural 03.11.2026).
 */

type Sekme = 'kalemler' | 'operasyon' | 'maliyet' | 'kalite' | 'izlenebilirlik' | 'denetim' | 'dokuman';


export function UretimFisiKartiSayfa() {
  const { id } = useParams();
  const [sorgu] = useSearchParams();
  const konum = useLocation();
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const kapat = useKartKapat('/uretim-fisi', sorgu.get('geri'));
  const yeni = id === 'yeni';
  const fisId = yeni ? null : Number(id);
  useEffect(() => { ekranSekmesi?.baslik(c(yeni ? 'Yeni Üretim Fişi' : 'Üretim Fişi'), konum.pathname, '🏭') },
    [ekranSekmesi, konum.pathname, yeni]);
  if (!yeni && !(fisId! > 0)) return null;
  return <UretimFisiKarti key={id} fisId={fisId} onKapat={kapat}
                          onStokId={Number(sorgu.get('stokId')) || null} onEmirId={Number(sorgu.get('emirId')) || null}
                          onMiktar={Number(sorgu.get('miktar')) || null} />;
}

function UretimFisiKarti({ fisId, onKapat, onStokId, onEmirId, onMiktar }: {
  fisId: number | null; onKapat(): void; onStokId: number | null; onEmirId: number | null; onMiktar: number | null;
}) {
  const { yetki, aksiyonVar } = useOturum();
  const sv = useUretimSeviyesi();
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const sekmedeAc = useSekmedeAc();
  const [yukleniyor, setYukleniyor] = useState(true);
  const [kayitli, setKayitli] = useState<FisYaniti | null>(null);
  const [hata, setHata] = useState('');
  const [mesgul, setMesgul] = useState(false);
  const [sekme, setSekme] = useState<Sekme>('kalemler');

  // ---- başlık alanları
  const [mamul, setMamul] = useState<MamulBilgisi | null>(null);
  const [agacId, setAgacId] = useState<number | null>(null);
  const [agacKod, setAgacKod] = useState(''); const [agacSurum, setAgacSurum] = useState(0);
  const [emirId, setEmirId] = useState<number | null>(onEmirId);
  const [miktar, setMiktar] = useState(onMiktar ? String(onMiktar) : '1');
  const [bas, setBas] = useState(yerelAnMetni(new Date()));
  const [bit, setBit] = useState('');
  const [sarfDepoId, setSarfDepoId] = useState<number | null>(null);
  const [girisDepoId, setGirisDepoId] = useState<number | null>(null);
  const [girisDepoAcik, setGirisDepoAcik] = useState(false);
  const [isMerkeziId, setIsMerkeziId] = useState<number | null>(null);
  const [sorumluId, setSorumluId] = useState<number | null>(null);
  const [partiNo, setPartiNo] = useState('');
  const [maliyetYontemi, setMaliyetYontemi] = useState(2);
  const [otomatikHesap, setOtomatikHesap] = useState(true);
  const [aciklama, setAciklama] = useState('');
  const [satirlar, setSatirlar] = useState<FisSatiri[]>([]);
  const [operasyonlar, setOperasyonlar] = useState<FisOperasyonu[]>([]);
  const [kontroller, setKontroller] = useState<FisKontrolu[]>([]);
  const [kirli, setKirli] = useState(false);

  // ---- seçim listeleri
  const [depolar, setDepolar] = useState<{ id: number; ad: string }[]>([]);
  const [isMerkezleri, setIsMerkezleri] = useState<{ id: number; ad: string }[]>([]);
  const [personel, setPersonel] = useState<{ id: number; ad: string }[]>([]);
  useEffect(() => {
    void api.liste('depo', { sayfa: 1, boyut: 200, sirala: [{ alan: 'ad', yon: 'asc' }], filtre: { alan: 'durum', op: 'esit', deger: 1 } })
      .then(y => setDepolar(y.satirlar.map(s => ({ id: Number(s.id), ad: String(s.ad ?? '') })))).catch(() => setDepolar([]));
    void api.liste('is-merkezi', { sayfa: 1, boyut: 200, sirala: [{ alan: 'ad', yon: 'asc' }], filtre: { alan: 'durum', op: 'esit', deger: 0 } })
      .then(y => setIsMerkezleri(y.satirlar.map(s => ({ id: Number(s.id), ad: String(s.ad ?? '') })))).catch(() => setIsMerkezleri([]));
    void api.liste('personel', { sayfa: 1, boyut: 300, sirala: [{ alan: 'unvan', yon: 'asc' }], filtre: { alan: 'durum', op: 'esit', deger: 1 } })
      .then(y => setPersonel(y.satirlar.map(s => ({ id: Number(s.id), ad: String(s.unvan ?? '') })))).catch(() => setPersonel([]));
  }, []);

  const fis = kayitli?.fis ?? null;
  const durum = fis?.durum ?? 1;
  const taslak = durum === 1;
  // 1261: Delphi'den aktarılan fiş - tek belge; Sil / ters kayıt yok, rozet gösterilir.
  const aktarim = !!fis?.aktarimTablo;
  const salt = !taslak;                    // gerçekleşmiş fiş değişmez (ters kayıt + yeni fiş)
  const yazar = yetki('uretim.fis', fisId ? 'degistir' : 'ekle');
  const duzenlenir = yazar && !salt;

  // ---- yükle
  const yukle = useCallback(async () => {
    if (!fisId) return;
    setYukleniyor(true);
    try {
      const y = await api.uretimFisOku(fisId);
      setKayitli(y);
      const f = y.fis;
      setMamul(await api.uretimMamul(f.stokId).catch(() => null));
      setAgacId(f.agacId); setAgacKod(f.agacKod); setAgacSurum(f.agacSurum); setEmirId(f.emirId);
      setMiktar(String(f.miktar)); setBas(anGirdi(f.bas)); setBit(anGirdi(f.bit));
      setSarfDepoId(f.sarfDepoId); setGirisDepoId(f.girisDepoId); setGirisDepoAcik(!!f.girisDepoId && f.girisDepoId !== f.sarfDepoId);
      setIsMerkeziId(f.isMerkeziId); setSorumluId(f.sorumluId); setPartiNo(f.partiNo);
      setMaliyetYontemi(f.maliyetYontemi); setOtomatikHesap(f.otomatikHesap === 1); setAciklama(f.aciklama);
      setSatirlar(y.satirlar.map(s => ({ ...s, depoKalan: s.grup === 1 ? Number(s.depoKalan) : -1 })));
      setOperasyonlar(y.operasyonlar); setKontroller(y.kontroller);
      setKirli(false); setHata('');
    } catch (h) { setHata(hataMetni(h)) } finally { setYukleniyor(false) }
  }, [fisId]);
  useEffect(() => { void yukle() }, [yukle]);

  // ---- yeni fiş: mamul seçimi (alış / satışta cari arama gibi; iptal = kart kapanır)
  const [mamulAra, setMamulAra] = useState(false);
  useEffect(() => {
    if (fisId) return;
    setYukleniyor(false);
    if (onStokId) void mamulSec(onStokId, onMiktar ?? 1);
    else setMamulAra(true);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [fisId]);

  async function mamulSec(stokId: number, miktarIlk?: number) {
    setMesgul(true);
    try {
      const m = await api.uretimMamul(stokId);
      setMamul(m);
      setSarfDepoId(d => d ?? m.sarfDepoId ?? depolar[0]?.id ?? null);
      setGirisDepoId(d => d ?? m.mamulDepoId ?? null);
      setGirisDepoAcik(!!m.mamulDepoId && m.mamulDepoId !== (m.sarfDepoId ?? null));
      setAgacId(m.agacId); setAgacKod(m.agacKod ?? ''); setAgacSurum(m.agacSurum ?? 0);
      const mk0 = miktarIlk ?? (Number(miktar.replace(',', '.')) || 1);
      setMiktar(String(mk0));
      if (m.agacId) await agactanDoldur(stokId, m.agacId, mk0, m.sarfDepoId ?? sarfDepoId, false);
      else setSatirlar([bosSatir(4, { stokId, stokKod: m.kod, stokAd: m.ad, izleme: m.izleme, anaUrun: true, birimIhtiyac: 1, planMiktar: mk0,
                                        miktar: mk0, birim: m.birimKodu, birimAdi: m.birimAdi, aciklama: 'ana ürün' })]);
      setKirli(true);
    } catch (h) { setHata(hataMetni(h)) } finally { setMesgul(false) }
  }

  /** ÜRÜN AĞACINDAN DOLDUR: ağaçtan gelen satırlar yenilenir, elle eklenenler (birimIhtiyac 0 sarf, gider, fire, yan ürün) kalır. */
  async function agactanDoldur(stokId: number, agac: number | null, mk0: number, depo: number | null, sor = true) {
    const agactan = satirlar.filter(s => (s.grup === 1 && s.birimIhtiyac > 0) || (s.grup === 4 && s.anaUrun) || (s.grup === 2 && s.aciklama.startsWith('operasyon')));
    if (sor && agactan.some(s => s.izlemler?.length || (s.grup === 1 && s.planMiktar !== s.miktar))
        && !await onay(c('Ağaçtan gelen satırlarda elle değişiklik var. Ağaçtan yenilensin mi? (lot seçimleri ve değişen miktarlar sıfırlanır)'))) return;
    const y = await api.uretimFisDoldur({ stokId, agacId: agac, miktar: mk0, sarfDepoId: depo, maliyetYontemi });
    const elle = satirlar.filter(s => !((s.grup === 1 && s.birimIhtiyac > 0) || (s.grup === 4 && s.anaUrun) || (s.grup === 2 && s.aciklama.startsWith('operasyon'))));
    let gelen: FisSatiri[] = y.satirlar.map(s => ({ ...s, izlemler: null, depoKalan: s.grup === 1 ? Number(s.depoKalan) : -1 }));
    // BASİT: işçilik tek tutar - operasyon satırları tek "İşçilik / gider" satırına toplanır (ağaçtan: N saat × ücret).
    if (sv.basit) {
      const giderler = gelen.filter(s => s.grup === 2);
      if (giderler.length) {
        const toplam = giderler.reduce((a, s) => a + satirTutar(s), 0);
        const saat = giderler.reduce((a, s) => a + s.miktar, 0);
        gelen = [...gelen.filter(s => s.grup !== 2), bosSatir(2, { stokAd: 'İşçilik / gider', ad: 'İşçilik / gider', miktar: 1, birimAdi: '',
          birimMaliyet: Math.round(toplam * 100) / 100, aciklama: `operasyon: ağaçtan (${mk(saat)} saat)` })];
      }
    }
    setSatirlar([...gelen, ...elle].map((s, i) => ({ ...s, sira: i + 1 })));
    setAgacId(y.agac.id); setAgacKod(y.agac.kod); setAgacSurum(y.agac.surum);
    setKirli(true);
  }

  // ---- miktar değişince ağaçtan gelenler oranlanır
  const miktarSayi = Number(miktar.replace(',', '.')) || 0;
  const miktarDegis = (v: string) => {
    setMiktar(v);
    const n = Number(v.replace(',', '.')) || 0;
    if (n > 0) setSatirlar(l => fisSatirlariniOranla(l, n));
    setKirli(true);
  };

  // ---- satır düzenleme
  const satirDegis = (i: number, d: Partial<FisSatiri>) => {
    setSatirlar(l => l.map((s, k) => (k === i ? { ...s, ...d, tutar: satirTutar({ ...s, ...d }) } : s)));
    setKirli(true);
  };
  const satirSil = (i: number) => { setSatirlar(l => l.filter((_, k) => k !== i)); setKirli(true) };
  const [stokAra, setStokAra] = useState<FisGrup | null>(null);
  const stokEkle = (satir: ListeSatiri) => {
    const grup = stokAra!;
    setSatirlar(l => [...l, bosSatir(grup, {
      sira: l.length + 1, stokId: Number(satir.id), stokKod: String(satir.kod ?? ''), stokAd: String(satir.ad ?? ''),
      izleme: Number(satir.izleme ?? 0), birim: Number(satir.anaBirimKod ?? 0), birimAdi: String(satir.anaBirim ?? ''), miktar: grup === 3 ? 0 : 1,
      aciklama: grup === 4 ? 'yan ürün' : '', elleMaliyet: grup === 4,
    })]);
    setStokAra(null); setKirli(true);
  };
  const giderEkle = () => {
    setSatirlar(l => [...l, bosSatir(2, { sira: l.length + 1, stokAd: '', ad: '', miktar: 1, birimAdi: 'Saat' })]);
    setKirli(true);
  };

  // ---- lot / seri penceresi
  const [izlemSatiri, setIzlemSatiri] = useState<number | null>(null);
  const izlemToIzlemSatiri = (z: FisIzlem): IzlemSatiri => ({
    seriLotId: z.seriLotId ?? undefined, lotNo: z.lotNo ?? '', seriNo: z.seriNo ?? '', uretimTarihi: z.uretimTarihi?.slice(0, 10) ?? '',
    sonKullanmaTarihi: z.sonKullanmaTarihi?.slice(0, 10) ?? '', durum: z.durum ?? 0, miktar: String(z.miktar),
  });
  const izlemDen = (z: IzlemSatiri): FisIzlem => ({
    seriLotId: z.seriLotId ?? null, lotNo: z.lotNo, seriNo: z.seriNo, uretimTarihi: z.uretimTarihi || null,
    sonKullanmaTarihi: z.sonKullanmaTarihi || null, durum: z.durum, miktar: Number(String(z.miktar).replace(',', '.')) || 0,
  });

  // ---- maliyet önizlemesi / eksik
  const onizleme = useMemo(() => fisMaliyeti(satirlar), [satirlar]);
  const eksikler = satirlar.filter(eksikMi);
  const enCok = useMemo(() => enCokUretilir(satirlar), [satirlar]);

  // ---- istek gövdesi
  const govde = (gerceklestir: boolean, eksiyeIzin: boolean): FisIstegi => ({
    stokId: mamul!.id, agacId, emirId, miktar: miktarSayi, bas: bas || null, bit: bit || null,
    sarfDepoId, girisDepoId: girisDepoAcik ? girisDepoId : sarfDepoId, isMerkeziId, sorumluId, onaylayanId: null, projeId: null,
    partiNo, maliyetYontemi, otomatikHesap, aciklama,
    satirlar: satirlar.filter(s => s.miktar > 0 || s.grup === 2).map(s => ({
      grup: s.grup, stokId: s.grup === 2 ? null : s.stokId, masrafId: null, ad: s.grup === 2 ? (s.ad || s.stokAd) : '', anaUrun: s.anaUrun,
      birimIhtiyac: s.birimIhtiyac, planMiktar: s.planMiktar, miktar: s.miktar, birim: s.birim, birimMaliyet: s.birimMaliyet,
      elleMaliyet: s.elleMaliyet, fireTuru: s.fireTuru, izlemler: s.izlemler?.length ? s.izlemler : null, aciklama: s.aciklama,
    })),
    operasyonlar: operasyonlar.map(o => ({ sira: o.sira, ad: o.ad, tarafId: o.tarafId, isMerkeziId: o.isMerkeziId, bas: o.bas, bit: o.bit,
      molaDk: o.molaDk, sureSaat: o.sureSaat, adet: o.adet, saatUcreti: o.saatUcreti, durum: o.durum, aciklama: o.aciklama })),
    kontroller: kontroller.map(k => ({ ad: k.ad, kriter: k.kriter, sonuc: k.sonuc, notu: k.notu })),
    gerceklestir, eksiyeIzin, surum: fis?.surum ?? null,
  });

  const tazele = () => window.dispatchEvent(new CustomEvent(LISTE_TAZELE_OLAYI, { detail: 'uretim-fisi' }));

  /** Kaydet: basit = kaydet + stoğa işle; standart / denetimli = taslak (Gerçekleştir ayrı). Sonra sekme kapanır. */
  async function kaydet(gerceklestir: boolean, eksiyeIzin = false) {
    if (!mamul) { setHata(c('Mamul seçilmeli.')); return }
    if (!(miktarSayi > 0)) { setHata(c('Miktar sıfırdan büyük olmalı.')); return }
    if (!sarfDepoId) { setHata(c('Sarf deposu seçilmeli.')); return }
    if (gerceklestir && eksikler.length && !eksiyeIzin) {
      if (sv.denetimli) { setHata(c('Malzeme eksik - denetimli seviyede eksikle kayıt yapılmaz.')); return }
      setHata(''); return;        // uyarı kutusu yolu gösterir
    }
    setMesgul(true); setHata('');
    try {
      const g = govde(gerceklestir, eksiyeIzin);
      const y = fisId ? await api.uretimFisGuncelle(fisId, g) : await api.uretimFisEkle(g);
      tazele();
      if (emirId) window.dispatchEvent(new CustomEvent(LISTE_TAZELE_OLAYI, { detail: 'uretim-emri' }));
      mesaj([y.mesaj, ...y.uyarilar].join('\n'));
      onKapat();
    } catch (h) { setHata(hataMetni(h)) } finally { setMesgul(false) }
  }

  /** Sil: taslak gerçekten silinir; gerçekleşmiş fişte TERS KAYIT (denetimlide gerekçe zorunlu). Sonra sekme kapanır. */
  async function sil() {
    if (!fisId) return;
    if (taslak) {
      if (!await onay(c('Taslak fiş silinecek. Onaylıyor musunuz?'), true)) return;
      setMesgul(true);
      try { await api.uretimFisSil(fisId); tazele(); mesaj(c('Fiş silindi.')); onKapat() }
      catch (h) { setHata(hataMetni(h)) } finally { setMesgul(false) }
      return;
    }
    let neden = '';
    if (sv.denetimli) {
      const n = await metinSor(c('Ters kayıt gerekçesi (zorunlu):'), '', c('Gerekçe'));
      if (n === null) return;
      if (!n.trim()) { mesaj(c('Gerekçe zorunlu.')); return }
      neden = n.trim();
    } else if (!await onay(c('Kayıt silinmez: TERS KAYIT atılır - sarf geri gelir, mamul stoktan düşer, fiş iz olarak kalır. Devam?'), true)) return;
    setMesgul(true);
    try {
      const y = await api.uretimFisTersKayit(fisId, neden); tazele();
      if (emirId) window.dispatchEvent(new CustomEvent(LISTE_TAZELE_OLAYI, { detail: 'uretim-emri' }));
      mesaj(y.mesaj); onKapat();
    } catch (h) { setHata(hataMetni(h)) } finally { setMesgul(false) }
  }

  // ---- kalite (denetimli)
  const [serbestAcik, setSerbestAcik] = useState(false);
  // Aksiyon yetkisi (yetki.tur = 1): kaynak haritasında değil, oturumun aksiyon listesinde.
  const serbestYetki = aksiyonVar('uretim.fis.serbest');

  // ---- operasyon
  const oprDegis = (i: number, d: Partial<FisOperasyonu>) => { setOperasyonlar(l => l.map((o, k) => (k === i ? { ...o, ...d } : o))); setKirli(true) };
  const oprEkle = () => setOperasyonlar(l => [...l, { sira: l.length + 1, ad: '', tarafId: null, isMerkeziId: isMerkeziId, bas: null, bit: null,
    molaDk: 0, sureSaat: 0, adet: miktarSayi, saatUcreti: 0, durum: 1, aciklama: '' }]);
  const oprSure = (o: FisOperasyonu) => o.sureSaat || (o.bas && o.bit ? Math.max(0, (new Date(o.bit).getTime() - new Date(o.bas).getTime()) / 36e5 - o.molaDk / 60) : 0);
  /** İŞÇİLİĞE AKTAR: operasyon süreleri × saat ücreti → İşçilik / Gider grubu yeniden yazılır (taslakta). */
  const isciligeAktar = () => {
    const yeni = operasyonlar.filter(o => oprSure(o) > 0 && o.saatUcreti > 0).map(o => bosSatir(2, {
      stokAd: o.ad || 'Direkt işçilik', ad: o.ad || 'Direkt işçilik', miktar: Math.round(oprSure(o) * 1000) / 1000, birimAdi: 'Saat',
      birimMaliyet: o.saatUcreti, aciklama: `operasyon: ${o.ad}${o.personelAdi ? ' · ' + o.personelAdi : ''}` }));
    if (!yeni.length) { mesaj(c('Süresi ve saat ücreti dolu operasyon yok.')); return }
    setSatirlar(l => [...l.filter(s => s.grup !== 2), ...yeni].map((s, i) => ({ ...s, sira: i + 1, tutar: satirTutar(s) })));
    setKirli(true); setSekme('kalemler');
  };
  async function operasyonKaydet() {
    if (!fisId) return;
    setMesgul(true);
    try { const y = await api.uretimFisOperasyonYaz(fisId, govde(false, false).operasyonlar); setOperasyonlar(y.operasyonlar); mesaj(c('Operasyonlar kaydedildi.')) }
    catch (h) { setHata(hataMetni(h)) } finally { setMesgul(false) }
  }
  async function kontrolKaydet() {
    if (!fisId) return;
    setMesgul(true);
    try { const y = await api.uretimFisKontrolYaz(fisId, govde(false, false).kontroller); setKontroller(y.kontroller); mesaj(c('Kontrol listesi kaydedildi.')) }
    catch (h) { setHata(hataMetni(h)) } finally { setMesgul(false) }
  }


  // ---- kapatma: kayıtsız değişiklik sorusu sekmenin × tuşuna da bağlanır
  const kapatRef = useRef(onKapat);
  kapatRef.current = async () => {
    if (kirli && duzenlenir && !await onay(c('Kaydedilmemiş değişiklikler var. Kapatılsın mı?'), true)) return;
    onKapat();
  };
  useEffect(() => {
    if (!ekranSekmesi) return;
    ekranSekmesi.kapatmaIsleyicisi(() => void kapatRef.current(), () => kirli && duzenlenir);
    return () => ekranSekmesi.kapatmaIsleyicisi(null);
  }, [ekranSekmesi, kirli, duzenlenir]);

  if (yukleniyor) return <div className="yukleniyor">{c('Yükleniyor…')}</div>;

  const lotKolonu = sv.standartVe || satirlar.some(s => s.izleme > 0);
  const ad = mamul?.ad ?? fis?.stokAd ?? '';
  const sekmeler: [Sekme, string, boolean][] = [
    ['kalemler', `${c('Kalemler')}`, true],
    ['operasyon', c('Operasyon / Personel'), sv.standartVe],
    ['maliyet', c('Maliyet'), sv.standartVe],
    ['kalite', c('Kalite'), sv.denetimli],
    ['izlenebilirlik', c('İzlenebilirlik'), sv.denetimli && !!fisId],
    ['denetim', c('Denetim İzi'), sv.denetimli && !!fisId],
    ['dokuman', c('Resim / Doküman'), !!fisId],
  ];
  const sayac = (k: Sekme) => k === 'kalemler' ? satirlar.length : k === 'operasyon' ? operasyonlar.length : k === 'kalite' ? kontroller.length : 0;
  const adimlar = ['Taslak', 'Gerçekleşti', 'Kalite kontrol', 'Serbest'];
  const adimDurum = (i: number) => durum === 0 ? '' : durum === 1 ? (i === 0 ? 'simdi' : '') : durum === 2 ? (i <= 1 ? 'bitti' : i === 2 ? 'simdi' : '')
    : durum === 3 ? 'bitti' : (i <= 2 ? 'bitti' : '');
  const girisKalan = fis?.girisDepoKalan ?? Number((JSON.parse(mamul?.depolar || '[]') as { depoId: number; kalan: number }[])
    .find(d => d.depoId === (girisDepoAcik ? girisDepoId : sarfDepoId))?.kalan ?? 0);
  const birimMaliyetGoster = fis && durum >= 2 ? fis.birimMaliyet : onizleme.birim;

  return (
    <div className="uf">
      <style>{UF_STILI}</style>
      {/* ARAÇ ÇUBUĞU (mockup .arac): Kaydet · Sil / Ters Kayıt · tür adı mor · sağda serbest bırak · Kapat */}
      <div className="uf-arac">
        {duzenlenir && (sv.basit
          ? <button className="d yesil" disabled={mesgul} onClick={() => void kaydet(true)}>💾 {c('Kaydet')}</button>
          : <>
              <button className="d yesil" disabled={mesgul} onClick={() => void kaydet(false)}>💾 {c(fisId ? 'Kaydet' : 'Taslak Kaydet')}</button>
              <button className="d bir" disabled={mesgul} onClick={() => void kaydet(true)} title={c('Sarf çıkar, mamul girer, maliyet hesaplanır')}>✔ {c('Gerçekleştir')}</button>
            </>)}
        {fisId && durum !== 0 && !aktarim && yetki('uretim.fis', 'sil') && (
          taslak || !sv.denetimli
            ? <button className="d teh" disabled={mesgul} onClick={() => void sil()}
                      title={taslak ? c('Taslak silinir') : c('Kayıt silinmez: ters kayıt atılır, stok geri döner, iz kalır')}>🗑 {c('Sil')}</button>
            : <button className="d" disabled={mesgul} onClick={() => void sil()} title={c('Gerekçeli ters kayıt (Part 11)')}>↺ {c('Ters Kayıt')}</button>)}
        <span className="ayrac" />
        <span className="uf-tur">{c('ÜRETİM FİŞİ')} {fis && <small>#{fis.no}{fis.partiNo && sv.denetimli ? ` · Parti ${fis.partiNo}` : ''}</small>}</span>
        <span className="sp" />
        {fis && (
          <span className={`rozet ${durum === 2 ? (sv.denetimli ? 'uyari' : 'ok') : durum === 3 ? 'ok' : durum === 4 || durum === 0 ? 'hata' : 'gri'}`}>
            {fisDurumAdi(durum, fis.seviye)}</span>)}
        {aktarim && <span className="rozet gri" title={c('Delphi üretim fişinden aktarıldı: sarf ve mamul tek belgede, ters kayıt yapılamaz')}>{c('Delphi aktarımı')}</span>}
        {sv.denetimli && fisId && durum === 2 && serbestYetki && (
          <button className="d onay" onClick={() => setSerbestAcik(true)}>✔ {c('Serbest Bırak…')}</button>)}
        {ekranSekmesi ? null : <button className="d kapat-dugmesi" onClick={() => void kapatRef.current()}>✖ {c('Kapat')}</button>}
      </div>
      {sv.denetimli && (
        <div className="uf-adim">{adimlar.map((a, i) => <span key={a} className={`a ${adimDurum(i)}`}>{i + 1} {c(a)}</span>)}
          {durum === 0 && <span className="a hata">{c('Ters kayıt')}</span>}{durum === 4 && <span className="a hata">{c('Reddedildi')}</span>}</div>)}

      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="uf-bas">
        {/* MAMUL BANDI - cari bandının üretimdeki karşılığı */}
        <div className="uf-mbb">
          <div className="av">🏭</div>
          <div style={{ minWidth: 0 }}>
            <div className="ad">{ad || <span className="sl">{c('Mamul seçilmedi')}</span>}
              {mamul && <button type="button" className="k" title={c('Stok kartını aç')} onClick={() => sekmedeAc(`/stok/${mamul.id}`)}>↗</button>}
              {!fisId && <button type="button" className="k" title={c('Mamul değiştir')} onClick={() => setMamulAra(true)}>✎</button>}</div>
            {mamul && <div className="kim">Kod <b>{mamul.kod}</b> · Birim <b>{mamul.birimAdi || '—'}</b>
              {agacId ? <> · Ürün ağacı <b>{agacKod} v{agacSurum}</b></> : <> · <span className="eks">{c('ürün ağacı yok')}</span></>}
              {(sv.standartVe || mamul.izleme > 0) && <> · İzleme <b>{mamul.izleme ? izlemeAd(mamul.izleme) : 'yok'}</b></>}
              {mamul.kategori && <> · Kategori <b>{mamul.kategori}</b></>}</div>}
          </div>
          <div className="sag">
            <div className="kt mr"><span className="e">{durum >= 2 ? c('Üretilen') : c('Üretilecek')}</span>
              <span className="v">{mk(durum >= 2 ? fis!.uretilen : miktarSayi)} {mamul?.birimAdi}</span>
              <span className="a">{(girisDepoAcik ? depolar.find(d => d.id === girisDepoId)?.ad : depolar.find(d => d.id === sarfDepoId)?.ad) ?? ''}</span></div>
            {sv.standartVe && <div className="kt"><span className="e">{c('Stok (giriş depo)')}</span>
              <span className="v">{durum >= 2 ? mk(girisKalan) : `${mk(girisKalan)} → ${mk(girisKalan + miktarSayi)}`}</span></div>}
            <div className={`kt ${eksikler.length ? 'hata' : 'ok'}`}><span className="e">{c('Malzeme')}</span>
              <span className="v">{eksikler.length ? <>{c('Eksik')} <span className="rz hata">{eksikler.length} {c('kalem')}</span></> : c('Yeterli')}</span>
              <span className="a">{eksikler.length ? eksikler[0].stokAd.toLowerCase() : c('sarf deposunda')}</span></div>
            <div className="kt"><span className="e">{c('Birim maliyet')}</span><span className="v">{tl(birimMaliyetGoster)}</span>
              <span className="a">{durum >= 2 ? (maliyetYontemi === 1 ? c('son maliyetle') : c('ortalama maliyetle')) : c('tahmini')}</span></div>
            {sv.denetimli && fis && durum >= 2 && <div className={`kt ${durum === 2 ? 'uy' : durum === 3 ? 'ok' : 'hata'}`}><span className="e">{c('Stok durumu')}</span>
              <span className="v"><span className={`rz ${durum === 2 ? 'uy' : durum === 3 ? 'ok' : 'hata'}`}>{fisDurumAdi(durum, fis.seviye)}</span></span>
              <span className="a">{durum === 2 ? c('kalite onayı bekliyor') : durum === 3 ? fis.serbestAdi : fis.serbestGerekce}</span></div>}
          </div>
        </div>
        {/* BAŞLIK IZGARASI */}
        <div className="uf-iz">
          <label className="al"><span className="et">{c('Üretim No')}</span><input className="ro" readOnly value={fis?.no ?? c('kaydedince verilir')} /></label>
          <label className="al"><span className="et z">{c(sv.basit ? 'Tarih' : 'Başlama')}</span>
            <input type="datetime-local" value={bas} readOnly={salt} onChange={e => { setBas(e.target.value); setKirli(true) }} /></label>
          {sv.standartVe && <label className="al"><span className="et">{c('Bitiş')}</span>
            <input type="datetime-local" value={bit} readOnly={salt} onChange={e => { setBit(e.target.value); setKirli(true) }} /></label>}
          <label className="al"><span className="et z">{c('Miktar')}</span>
            <span className="uf-miktar"><input className="sg" value={miktar} readOnly={salt} onChange={e => miktarDegis(e.target.value)} /><span className="sl">{mamul?.birimAdi}</span></span></label>
          <label className="al"><span className="et z">{c(sv.basit ? 'Depo' : 'Sarf Deposu')}</span>
            <select value={sarfDepoId ?? 0} disabled={salt} onChange={e => { setSarfDepoId(Number(e.target.value) || null); setKirli(true) }}>
              <option value={0}>—</option>{depolar.map(d => <option key={d.id} value={d.id}>{d.ad}</option>)}</select></label>
          {sv.basit && !girisDepoAcik
            ? <div className="al"><span className="et" /><span className="sl kucuk">{c('malzeme bu depodan düşer, ürün buraya girer')} · {!salt && <button type="button" className="bag" onClick={() => setGirisDepoAcik(true)}>{c('farklı giriş deposu')}</button>}</span></div>
            : <label className="al"><span className="et">{c('Giriş Deposu')}</span>
                <select value={girisDepoId ?? 0} disabled={salt} onChange={e => { setGirisDepoId(Number(e.target.value) || null); setKirli(true) }}>
                  <option value={0}>— {c('sarf deposuyla aynı')} —</option>{depolar.map(d => <option key={d.id} value={d.id}>{d.ad}</option>)}</select></label>}
          <label className="al c2"><span className="et">{c('Açıklama')}</span>
            <input value={aciklama} maxLength={500} readOnly={salt} onChange={e => { setAciklama(e.target.value); setKirli(true) }} /></label>
          {(sv.standartVe || emirId) && <div className="al"><span className="et">{c('Kaynak')}</span>
            <span className="inp ro">{kayitli?.emir ? <button type="button" className="bag" onClick={() => sekmedeAc(`/uretim-emri/${kayitli.emir!.id}`)}>{c('Üretim Emri')} {kayitli.emir.no} ↗</button>
              : emirId ? `${c('Üretim Emri')} #${emirId}` : c('elle')}</span></div>}
          {sv.standartVe && <label className="al"><span className="et">{c('İş Merkezi')}</span>
            <select value={isMerkeziId ?? 0} disabled={salt} onChange={e => { setIsMerkeziId(Number(e.target.value) || null); setKirli(true) }}>
              <option value={0}>—</option>{isMerkezleri.map(d => <option key={d.id} value={d.id}>{d.ad}</option>)}</select></label>}
          {sv.standartVe && <label className="al"><span className="et">{c('Sorumlu')}</span>
            <select value={sorumluId ?? 0} disabled={salt} onChange={e => { setSorumluId(Number(e.target.value) || null); setKirli(true) }}>
              <option value={0}>—</option>{personel.map(d => <option key={d.id} value={d.id}>{d.ad}</option>)}</select></label>}
          {sv.denetimli && <label className="al"><span className="et">{c('Parti (Batch)')}</span>
            <input value={partiNo} maxLength={40} readOnly={salt} placeholder="P-261103-01" onChange={e => { setPartiNo(e.target.value); setKirli(true) }} /></label>}
        </div>
      </div>

      <div className="uf-sekmeler">
        {sekmeler.filter(s => s[2]).map(([k, b]) => (
          <button key={k} type="button" className={`sk${sekme === k ? ' on' : ''}`} onClick={() => setSekme(k)}>{b}{sayac(k) > 0 && <span className="say">{sayac(k)}</span>}</button>))}
      </div>

      {/* ======================================================== KALEMLER */}
      {sekme === 'kalemler' && (
        <div className="uf-panel">
          <div className="uf-karac">
            {duzenlenir && mamul && <>
              <button className="d mor" disabled={!agacId && mamul.agacSayisi === 0} title={agacId ? '' : c('Mamulün aktif ürün ağacı yok')}
                      onClick={() => void agactanDoldur(mamul.id, agacId, miktarSayi || 1, sarfDepoId)}>🌳 {c('Ürün Ağacından Doldur')}</button>
              <button className="d" onClick={() => setStokAra(1)}>＋ {c(sv.basit ? 'Malzeme' : 'Sarf')}</button>
              {sv.standartVe && <>
                <button className="d" onClick={() => setStokAra(4)}>＋ {c('Yan ürün')}</button>
                <button className="d" onClick={giderEkle}>＋ {c('Gider')}</button>
                <button className="d" onClick={() => setStokAra(3)}>＋ {c('Fire')}</button>
                <span className="ayrac" />
                <label className="chk"><input type="checkbox" checked={otomatikHesap} onChange={e => { setOtomatikHesap(e.target.checked); setKirli(true) }} /> {c('Otomatik hesapla')}</label>
                <span className="uf-seg" title={c('Sarf birim maliyeti')}>
                  <button type="button" className={maliyetYontemi === 1 ? 'on' : ''} onClick={() => { setMaliyetYontemi(1); setKirli(true) }}>{c('Son maliyet')}</button>
                  <button type="button" className={maliyetYontemi === 2 ? 'on' : ''} onClick={() => { setMaliyetYontemi(2); setKirli(true) }}>{c('Ortalama')}</button></span>
              </>}
              {sv.basit && <span className="sl kucuk">{c('Miktarı değiştirince malzemeler kendiliğinden oranlanır.')}</span>}
            </>}
            {salt && <span className="sl">🔒 {c('Gerçekleşmiş fiş - kalemler salt okunur. Düzeltme: Ters Kayıt + yeni fiş.')}</span>}
          </div>

          {eksikler.length > 0 && !salt && (
            <div className="uf-uyari">⚠ <b>{eksikler[0].stokAd}</b>: {depolar.find(d => d.id === sarfDepoId)?.ad ?? c('depo')}'da {mk(eksikler[0].depoKalan)} {eksikler[0].birimAdi} var,
              {' '}{mk(eksikler[0].miktar)} gerekiyor ({mk(eksikler[0].miktar - eksikler[0].depoKalan)} eksik){eksikler.length > 1 ? ` · ${eksikler.length - 1} kalem daha` : ''}.
              {enCok !== null && enCok > 0 && enCok < miktarSayi && (
                <button type="button" className="d" onClick={() => miktarDegis(String(enCok))}>{c('Miktarı')} {enCok} {c('adede düşür')}</button>)}
              {!sv.denetimli && <button type="button" className="d" onClick={() => void kaydet(true, true)}>{c('Yine de kaydet (stok eksiye düşer)')}</button>}
            </div>)}

          <table className="uf-dg">
            <thead><tr>
              <th style={{ width: 28 }}></th><th>{c('Kod')}</th><th>{c('Ad')}</th>
              {lotKolonu && <th>{c('Lot / Seri')}</th>}
              {sv.standartVe && <th className="sg">{c('Plan')}</th>}
              <th className="sg">{c('Miktar')}</th><th>{c('Birim')}</th><th className="sg">{c('Depoda')}</th>
              <th className="sg">{c('Birim Maliyet')}</th><th className="sg">{c('Tutar')}</th>
              {sv.standartVe && <th className="sg">{c('Sapma')}</th>}
              <th>{c('Açıklama')}</th>{duzenlenir && <th style={{ width: 28 }}></th>}
            </tr></thead>
            <tbody>
              {([1, 2, 3, 4] as FisGrup[]).filter(g => sv.standartVe || g === 1 || g === 4 || satirlar.some(s => s.grup === g)).map(g => {
                const l = satirlar.map((s, i) => [s, i] as const).filter(([s]) => s.grup === g);
                if (!l.length && (g === 2 || g === 3)) return null;
                const kol = 7 + (lotKolonu ? 1 : 0) + (sv.standartVe ? 2 : 0) + 1 + (duzenlenir ? 1 : 0);
                return [
                  <tr key={`g${g}`} className={`grup${g === 4 ? ' cikti' : g === 3 ? ' fire' : ''}`}><td colSpan={kol}>
                    {g === 4 ? '▲' : g === 3 ? '✖' : '▼'} {c(GRUP_AD[g])}
                    <span className="gs">{g === 1 ? `${depolar.find(d => d.id === sarfDepoId)?.ad ?? ''} · ${c('çıkar')}` : g === 2 ? c('masraf kalemi (stok oynatmaz, maliyete eklenir)')
                      : g === 3 ? c('normal fire maliyete girer · anormal fire dönem gideri') : `${(girisDepoAcik ? depolar.find(d => d.id === girisDepoId) : depolar.find(d => d.id === sarfDepoId))?.ad ?? ''} · ${c('girer')}`}</span></td></tr>,
                  ...(l.length ? l : [[null, -1] as const]).map(([s, i]) => s === null
                    ? <tr key={`b${g}`}><td colSpan={kol} className="sl bos">{g === 1 ? c('Sarf satırı yok - ürün ağacından doldurun ya da malzeme ekleyin.') : c('Satır yok')}</td></tr>
                    : <tr key={`${g}-${i}`} className={`${eksikMi(s) ? 'eksik' : ''}${s.fireTuru === 2 && g === 3 ? ' anormal' : ''}${s.anaUrun ? ' sel' : ''}`}>
                        <td className="or">{s.anaUrun ? <span className="ana" title={c('Ana ürün')}>★</span> : <span className="sl">{i + 1}</span>}</td>
                        <td>{s.stokKod}</td>
                        <td>{g === 2 ? (duzenlenir ? <input value={s.ad || s.stokAd} placeholder={c('Gider / işçilik adı')} onChange={e => satirDegis(i, { ad: e.target.value, stokAd: e.target.value })} /> : (s.ad || s.stokAd)) : s.stokAd}</td>
                        {lotKolonu && <td>{s.izleme > 0 && g !== 2
                          ? <button type="button" className={`lot${s.izlemler?.length ? '' : ' bos'}`} disabled={salt && !s.izlemler?.length} onClick={() => setIzlemSatiri(i)}>
                              {s.izlemler?.length ? s.izlemler.map(z => z.lotNo || z.seriNo || `#${z.seriLotId}`).join(', ') : g === 4 ? c('üretimde ver (otomatik)') : c('FEFO otomatik · lot seç')}</button>
                          : <span className="sl">—</span>}</td>}
                        {sv.standartVe && <td className="sg sl">{s.planMiktar ? mk(s.planMiktar) : ''}</td>}
                        <td className="sg">{duzenlenir ? <input className="sg dar" value={s.miktar} onChange={e => satirDegis(i, { miktar: Number(e.target.value.replace(',', '.')) || 0 })} /> : mk(s.miktar)}</td>
                        <td>{s.birimAdi}</td>
                        <td className={`sg${eksikMi(s) ? ' eks' : ''}`}>{g === 1 || g === 3 ? (s.depoKalan >= 0 ? mk(s.depoKalan) : '—') : <span className="sl">—</span>}</td>
                        <td className="sg">{duzenlenir && (g === 2 || g === 4 || !otomatikHesap)
                          ? <input className="sg dar" value={s.birimMaliyet} title={g === 4 && !s.anaUrun ? c('Yan ürün: elle değer (ana üründen düşülür)') : ''}
                                   readOnly={s.anaUrun} onChange={e => satirDegis(i, { birimMaliyet: Number(e.target.value.replace(',', '.')) || 0, elleMaliyet: g === 4 })} />
                          : s.anaUrun && durum < 2 ? <span className="sl" title={c('kayıtta hesaplanır')}>{tl(onizleme.birim)}</span> : s.birimMaliyet ? tl(s.birimMaliyet) : <span className="sl" title={c('kayıtta yöntemden okunur')}>—</span>}</td>
                        <td className="sg">{s.anaUrun && durum < 2 ? <span className="sl">{tl(onizleme.anaMaliyet)}</span> : tl(satirTutar(s))}</td>
                        {sv.standartVe && <td className={`sg ${s.planMiktar && s.miktar !== s.planMiktar ? 'uyy' : 'sl'}`}>
                          {g === 3 ? (duzenlenir ? <select value={s.fireTuru} onChange={e => satirDegis(i, { fireTuru: Number(e.target.value) as 1 | 2 })}><option value={1}>{c('Normal')}</option><option value={2}>{c('Anormal')}</option></select>
                                                  : <span className={`rz ${s.fireTuru === 2 ? 'hata' : 'gri'}`}>{s.fireTuru === 2 ? c('Anormal') : c('Normal')}</span>)
                            : s.planMiktar ? (s.miktar - s.planMiktar === 0 ? '0' : `${s.miktar > s.planMiktar ? '+' : ''}${mk(s.miktar - s.planMiktar)}`) : ''}</td>}
                        <td>{duzenlenir ? <input value={s.aciklama} onChange={e => satirDegis(i, { aciklama: e.target.value })} /> : s.aciklama}</td>
                        {duzenlenir && <td className="or">{!s.anaUrun && <button type="button" className="x" title={c('Satırı kaldır')} onClick={() => void (async () => { if (await onay(c('Satır kaldırılacak. Onaylıyor musunuz?'))) satirSil(i) })()}>✖</button>}</td>}
                      </tr>),
                ];
              })}
            </tbody>
          </table>

          {/* BASİT: fire tek alan + işçilik tek tutar */}
          {sv.basit && duzenlenir && (
            <div className="uf-basit-ek">
              <div className="al3"><span className="et">{c('Fire')}</span>
                {satirlar.some(s => s.grup === 3)
                  ? <span className="sl kucuk">{c('malzemeden düşer, maliyete dahil (yukarıdaki FİRE grubu)')}</span>
                  : <button type="button" className="d" onClick={() => setStokAra(3)}>＋ {c('Fire ekle')}</button>}
                <span className="sl kucuk">{c('çatlak, bozuk parça…')}</span></div>
              <div className="al3"><span className="et">{c('İşçilik / gider')}</span>
                <input className="sg" value={satirlar.filter(s => s.grup === 2).reduce((a, s) => a + satirTutar(s), 0) || ''} placeholder="0,00"
                       onChange={e => {
                         const t = Number(e.target.value.replace(',', '.')) || 0;
                         setSatirlar(l => [...l.filter(s => s.grup !== 2), ...(t > 0 ? [bosSatir(2, { stokAd: 'İşçilik / gider', ad: 'İşçilik / gider', miktar: 1, birimMaliyet: t, aciklama: 'elle' })] : [])]
                           .map((s, i) => ({ ...s, sira: i + 1 })));
                         setKirli(true);
                       }} />
                <span className="sl kucuk">{satirlar.find(s => s.grup === 2)?.aciklama.startsWith('operasyon') ? c('ürün ağacından · değiştirebilirsiniz') : c('tek tutar; ayrıntı için Standart seviye')}</span></div>
            </div>)}

          <div className="uf-ozet">
            <div className="oz"><div className="e">{c('Malzeme')}</div><div className="v">{tl(fis && durum >= 2 ? fis.malzeme : onizleme.malzeme)}</div></div>
            <div className="oz"><div className="e">{c('İşçilik / Gider')}</div><div className="v">{tl(fis && durum >= 2 ? fis.iscilik : onizleme.iscilik)}</div></div>
            {(sv.standartVe || onizleme.fireNormal > 0) && <div className="oz"><div className="e">{c('Fire')}</div><div className="v">{tl(fis && durum >= 2 ? fis.fireNormal : onizleme.fireNormal)}</div></div>}
            {(fis && durum >= 2 ? fis.fireAnormal : onizleme.fireAnormal) > 0 && <div className="oz uyy"><div className="e">{c('Anormal fire (gidere)')}</div><div className="v">{tl(fis && durum >= 2 ? fis.fireAnormal : onizleme.fireAnormal)}</div></div>}
            {(fis && durum >= 2 ? fis.yanUrun : onizleme.yanUrun) > 0 && <div className="oz"><div className="e">{c('Yan ürün (−)')}</div><div className="v">{tl(fis && durum >= 2 ? fis.yanUrun : onizleme.yanUrun)}</div></div>}
            <div className="oz"><div className="e">{c('Toplam')}</div><div className="v">{tl(fis && durum >= 2 ? fis.toplam : onizleme.anaMaliyet)}</div></div>
            <div className="oz vurgu"><div className="e">{c('Birim maliyet')}</div><div className="v">{tl(birimMaliyetGoster)}</div></div>
          </div>
        </div>)}

      {/* ======================================================== OPERASYON */}
      {sekme === 'operasyon' && (
        <div className="uf-panel">
          <div className="uf-karac">
            {durum !== 0 && yazar && <button className="d" onClick={oprEkle}>＋ {c('Yeni')}</button>}
            {duzenlenir && <button className="d mor" onClick={isciligeAktar} title={c('süre × saat ücreti → Kalemler › İşçilik / Gider')}>⇢ {c('İşçiliğe Aktar')}</button>}
            {fisId && durum >= 2 && yazar && <button className="d bir" disabled={mesgul} onClick={() => void operasyonKaydet()}>💾 {c('Operasyonları Kaydet')}</button>}
            <span className="sl kucuk">{c('Kim, hangi işte, ne kadar çalıştı. Süre boşsa bitiş − başlama − mola.')}</span>
          </div>
          <table className="uf-dg">
            <thead><tr><th>{c('Operasyon')}</th><th>{c('Personel')}</th><th>{c('İş Merkezi')}</th><th>{c('Başlama')}</th><th>{c('Bitiş')}</th>
              <th className="sg">{c('Mola (dk)')}</th><th className="sg">{c('Süre (saat)')}</th><th className="sg">{c('Adet')}</th><th className="sg">{c('Saat Ücreti')}</th><th>{c('Durum')}</th><th>{c('Açıklama')}</th>{yazar && <th />}</tr></thead>
            <tbody>
              {operasyonlar.map((o, i) => (
                <tr key={i}>
                  <td><input value={o.ad} readOnly={!yazar || durum === 0} onChange={e => oprDegis(i, { ad: e.target.value })} /></td>
                  <td><select value={o.tarafId ?? 0} disabled={!yazar} onChange={e => oprDegis(i, { tarafId: Number(e.target.value) || null, personelAdi: personel.find(p => p.id === Number(e.target.value))?.ad })}>
                    <option value={0}>—</option>{personel.map(p => <option key={p.id} value={p.id}>{p.ad}</option>)}</select></td>
                  <td><select value={o.isMerkeziId ?? 0} disabled={!yazar} onChange={e => oprDegis(i, { isMerkeziId: Number(e.target.value) || null })}>
                    <option value={0}>—</option>{isMerkezleri.map(m => <option key={m.id} value={m.id}>{m.ad}</option>)}</select></td>
                  <td><input type="datetime-local" value={anGirdi(o.bas)} readOnly={!yazar} onChange={e => oprDegis(i, { bas: e.target.value || null })} /></td>
                  <td><input type="datetime-local" value={anGirdi(o.bit)} readOnly={!yazar} onChange={e => oprDegis(i, { bit: e.target.value || null })} /></td>
                  <td className="sg"><input className="sg dar" value={o.molaDk} readOnly={!yazar} onChange={e => oprDegis(i, { molaDk: Number(e.target.value) || 0 })} /></td>
                  <td className="sg"><input className="sg dar" value={o.sureSaat || ''} placeholder={oprSure(o) ? mk(oprSure(o)) : ''} readOnly={!yazar} onChange={e => oprDegis(i, { sureSaat: Number(e.target.value.replace(',', '.')) || 0 })} /></td>
                  <td className="sg"><input className="sg dar" value={o.adet} readOnly={!yazar} onChange={e => oprDegis(i, { adet: Number(e.target.value.replace(',', '.')) || 0 })} /></td>
                  <td className="sg"><input className="sg dar" value={o.saatUcreti || ''} placeholder={c('iş merkezinden')} readOnly={!yazar} onChange={e => oprDegis(i, { saatUcreti: Number(e.target.value.replace(',', '.')) || 0 })} /></td>
                  <td><select value={o.durum} disabled={!yazar} onChange={e => oprDegis(i, { durum: Number(e.target.value) })}><option value={1}>{c('Tamamlandı')}</option><option value={0}>{c('Devam')}</option></select></td>
                  <td><input value={o.aciklama} readOnly={!yazar} onChange={e => oprDegis(i, { aciklama: e.target.value })} /></td>
                  {yazar && <td className="or"><button type="button" className="x" onClick={() => { setOperasyonlar(l => l.filter((_, k) => k !== i)); setKirli(true) }}>✖</button></td>}
                </tr>))}
              {operasyonlar.length > 0 && <tr className="top"><td colSpan={6}>{c('Toplam')}</td><td className="sg">{mk(operasyonlar.reduce((a, o) => a + oprSure(o), 0))}</td><td colSpan={4 + (yazar ? 1 : 0)} /></tr>}
              {operasyonlar.length === 0 && <tr><td colSpan={12} className="sl bos">{c('Operasyon kaydı yok.')}</td></tr>}
            </tbody>
          </table>
        </div>)}

      {sekme === 'kalite' && (
        <div className="uf-panel">
          <div className="uf-karac">
            {durum < 3 && durum !== 0 && yazar && <button className="d" onClick={() => { setKontroller(l => [...l, { sira: l.length + 1, ad: '', kriter: '', sonuc: 0, notu: '' }]); setKirli(true) }}>＋ {c('Kontrol')}</button>}
            {durum < 3 && durum !== 0 && yazar && kontroller.length === 0 && <button className="d" onClick={() => { setKontroller(VARSAYILAN_KONTROLLER.map((k, i) => ({ sira: i + 1, ...k, sonuc: 0, notu: '' }))); setKirli(true) }}>📋 {c('Standart liste')}</button>}
            {fisId && durum === 2 && yazar && <button className="d bir" disabled={mesgul} onClick={() => void kontrolKaydet()}>💾 {c('Listeyi Kaydet')}</button>}
            <span className="sl kucuk">{c('ISO 9001 §8.6 · 13485 §8.2.6: kabul kriterli kontroller; hepsi uygun olmadan serbest bırakma yok.')}</span>
            <span className="sp" />
            <span className={`rz ${kontroller.length && kontroller.every(k => k.sonuc === 1) ? 'ok' : 'uy'}`}>{kontroller.filter(k => k.sonuc === 1).length} / {kontroller.length}</span>
          </div>
          <table className="uf-dg kucuk">
            <thead><tr><th>{c('Kontrol')}</th><th>{c('Kabul kriteri')}</th><th>{c('Sonuç')}</th><th>{c('Yapan · zaman')}</th><th>{c('Not')}</th>{durum < 3 && yazar && <th />}</tr></thead>
            <tbody>
              {kontroller.map((k, i) => (
                <tr key={i}>
                  <td><input value={k.ad} readOnly={durum >= 3 || !yazar} onChange={e => { setKontroller(l => l.map((x, j) => j === i ? { ...x, ad: e.target.value } : x)); setKirli(true) }} /></td>
                  <td><input value={k.kriter} readOnly={durum >= 3 || !yazar} onChange={e => { setKontroller(l => l.map((x, j) => j === i ? { ...x, kriter: e.target.value } : x)); setKirli(true) }} /></td>
                  <td>{durum < 3 && yazar
                    ? <select value={k.sonuc} onChange={e => { setKontroller(l => l.map((x, j) => j === i ? { ...x, sonuc: Number(e.target.value) } : x)); setKirli(true) }}>
                        <option value={0}>{c('Bekliyor')}</option><option value={1}>{c('Uygun')}</option><option value={2}>{c('Uygunsuz')}</option></select>
                    : <span className={`rz ${k.sonuc === 1 ? 'ok' : k.sonuc === 2 ? 'hata' : 'gri'}`}>{k.sonuc === 1 ? c('Uygun') : k.sonuc === 2 ? c('Uygunsuz') : c('Bekliyor')}</span>}</td>
                  <td className="sl">{k.yapanAdi ? `${k.yapanAdi} · ${tarihSaat(k.zaman)}` : '—'}</td>
                  <td><input value={k.notu} readOnly={durum >= 3 || !yazar} onChange={e => { setKontroller(l => l.map((x, j) => j === i ? { ...x, notu: e.target.value } : x)); setKirli(true) }} /></td>
                  {durum < 3 && yazar && <td className="or"><button type="button" className="x" onClick={() => { setKontroller(l => l.filter((_, j) => j !== i)); setKirli(true) }}>✖</button></td>}
                </tr>))}
              {kontroller.length === 0 && <tr><td colSpan={6} className="sl bos">{c('Kontrol listesi boş - "Standart liste" ile başlayın ya da kontrol ekleyin.')}</td></tr>}
            </tbody>
          </table>
          {fis && (fis.serbestAn || durum >= 3) && (
            <div className="uf-imza">✍ <b>{durum === 3 ? c('Serbest bırakıldı') : c('Reddedildi')}</b> · {fis.serbestAdi} · {tarihSaat(fis.serbestAn)} · {c('gerekçe')}: {fis.serbestGerekce}</div>)}
          {fisId && durum === 2 && serbestYetki && (
            <div className="uf-karac"><button className="d onay" onClick={() => setSerbestAcik(true)}>✔ {c('İmzala ve serbest bırak / reddet…')}</button>
              <span className="sl kucuk">{c('e-imza: parola tekrarı + gerekçe + anlam; kayıt değiştirilemez (Part 11 §11.50).')}</span></div>)}
        </div>)}

      {/* ======================================================== MALİYET */}
      {sekme === 'maliyet' && (
        <MaliyetPaneli birimAdi={mamul?.birimAdi ?? ''} belgeler={kayitli?.belgeler ?? []}
          m={fis && durum >= 2 ? { malzeme: fis.malzeme, iscilik: fis.iscilik, fireNormal: fis.fireNormal, fireAnormal: fis.fireAnormal,
                                   yanUrun: fis.yanUrun, anaMaliyet: fis.toplam, birim: fis.birimMaliyet, anaMiktar: fis.uretilen } : onizleme} />)}

      {/* ======================================================== KALİTE */}

      {sekme === 'izlenebilirlik' && fisId && <IzlenebilirlikPaneli fisId={fisId} durum={durum} belgeler={kayitli?.belgeler ?? []} />}
      {sekme === 'denetim' && fisId && <DenetimIziPaneli fisId={fisId} />}
      {sekme === 'dokuman' && fisId && (
        <div className="uf-panel"><DokumanGalerisi kartAdi="uretim-fisi" kaynakId={fisId} saltOkunur={!yazar} /></div>)}

      {/* ======================================================== PENCERELER */}
      {mamulAra && (
        <StokAramaPenceresi etkin yalnizStok tekSecim
          onSec={s => { setMamulAra(false); void mamulSec(Number(s.id)) }}
          onKapat={() => { setMamulAra(false); if (!mamul) onKapat() }} />)}
      {stokAra !== null && (
        <StokAramaPenceresi etkin yalnizStok tekSecim onSec={stokEkle} onKapat={() => setStokAra(null)} />)}
      {izlemSatiri !== null && satirlar[izlemSatiri] && (
        <IzlemPenceresi stokAdi={satirlar[izlemSatiri].stokAd} stokId={satirlar[izlemSatiri].stokId} izleme={satirlar[izlemSatiri].izleme}
          miktar={satirlar[izlemSatiri].miktar} cikis={satirlar[izlemSatiri].grup !== 4}
          depoId={satirlar[izlemSatiri].grup === 4 ? (girisDepoAcik ? girisDepoId : sarfDepoId) : sarfDepoId}
          satirlar={(satirlar[izlemSatiri].izlemler ?? []).map(izlemToIzlemSatiri)}
          onKapat={() => setIzlemSatiri(null)}
          onKaydet={l => { satirDegis(izlemSatiri, { izlemler: l.map(izlemDen) }); setIzlemSatiri(null) }} />)}
      {serbestAcik && fisId && (
        <FisSerbestPenceresi fisId={fisId} kontrolTamam={kontroller.length > 0 && kontroller.every(k => k.sonuc === 1)}
          onKapat={() => setSerbestAcik(false)} onBitti={() => { setSerbestAcik(false); tazele(); void yukle() }} />)}
    </div>
  );
}
