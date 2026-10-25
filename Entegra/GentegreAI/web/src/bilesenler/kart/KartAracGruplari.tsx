import { useState, type Dispatch, type ReactNode, type SetStateAction } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni, type KartMetaYaniti } from '../../api/sozlesme';
import { c } from '../../dil/ceviri';
import { useOturum } from '../../kimlik/OturumBaglami';
import { type DetayDurumu, type Satir, bosDetay } from '../detayDurumu';
import { dokumanDosyaAdi, dosyaIndirUrl } from '../indir';
import type { Deger } from '../kartAlanCizim';
import { guvenli, mesaj as bilgiMesaji, onay as onaySor } from '../mesaj';
import { RandevuErtelePenceresi } from '../RandevuErtelePenceresi';
import { RandevuSeriPenceresi } from '../RandevuSeriPenceresi';
import { DevirPenceresi } from '../../sayfalar/cari/CariDevirPenceresi';

/**
 * KART ARAÇ ÇUBUĞU - KAYNAĞA ÖZEL GRUPLAR (refaktör 22.10.2026, GenForm'dan ayrıldı).
 *
 * GenForm'un alt araç çubuğu (Kaydet · Sil · ... · Kapat) her ekranın kendi düğmelerini
 * `kaynak === '...'` dallarıyla çiziyordu. Gruplar burada: `kartAracGrubu` Sil'in sağındaki
 * (ekran eylemleri + hatırlatmadan sonra) yere, `kartSagAraclari` Kapat'ın sağına gelir.
 * Kendi durumu olan gruplar (hasta kimlik sorguları, randevu ertele / tekrarla pencereleri)
 * bileşen - durumu da pencereleri de kendinde.
 */
export interface KartAracBaglami {
  kaynak: string;
  id: number | 'yeni';
  yeniMi: boolean;
  salt: boolean;
  meta: KartMetaYaniti;
  deger: Record<string, Deger>;
  setDeger: Dispatch<SetStateAction<Record<string, Deger>>>;
  alanDegistir(ad: string, v: Deger): void;
  detaylar: Record<string, DetayDurumu>;
  setDetaylar: Dispatch<SetStateAction<Record<string, DetayDurumu>>>;
  setHata(h: string | null): void;
  kaydedilmemisDegisiklikVar: boolean;
  kaydet(acikKal?: boolean, sonra?: (id: number) => Promise<void>): Promise<unknown>;
  basvuruAc(): void;
  onKaydedildi?(id: number): void;
  onKapat?(): void;
  gizliAlanlar?: string[];
  cariyeBaglaGizli?: boolean;
  cariyeBagla(): void;
}

/** Sil'in sağındaki kaynağa özel grup (yoksa null). */
export function kartAracGrubu(b: KartAracBaglami): ReactNode {
  switch (b.kaynak) {
    case 'hasta': return <HastaKimlikAraclari b={b} />;
    case 'cari': return b.yeniMi ? null : <CariEkstreDugmesi tarafId={Number(b.id)} ad={String(b.deger.unvan ?? '')} />;
    case 'hesap': return b.yeniMi ? null : <HesapAraclari hesapId={Number(b.id)} tur={String(b.deger.tur ?? '')} />;
    // Kisi'ye ozel: "Bagli Cari" alani artik salt-okunur gorunum (asagida renderGirdi),
    //   tek degistirme yolu bu buton + TarafArama modali. Kisi zaten bagliysa (bagId
    //   dolu) buton GORUNMEZ (kullanici) - once "x" ile bag bosaltilmali.
    case 'kisi':
      return !b.salt && !b.cariyeBaglaGizli && !b.deger.bagId
        ? <button className="d" onClick={b.cariyeBagla}>🔗 Cariye Bağla</button> : null;
    case 'cek-senet': return <CekSenetYonu b={b} />;
    case 'hasta-aday': return <AdayDurumRozeti b={b} />;
    case 'randevu': return b.salt ? null : <RandevuKartAraclari b={b} />;
    case 'dokuman': return b.yeniMi ? null : <DokumanKartAraclari b={b} />;
    case 'entegrasyon-hesap': return b.yeniMi ? null : <EntegrasyonKartAraclari b={b} />;
    default: return null;
  }
}

/** Kapat'ın sağındaki grup (yoksa null). */
export function kartSagAraclari(b: KartAracBaglami): ReactNode {
  return b.kaynak === 'cari' ? <CariRolKutulari b={b} /> : null;
}

/*
 * HASTA KARTI EYLEM DUGMELERI (kullanici) - Sil'in saginda.
 * MERNİS / KPS (kullanıcı 19.10.2026: "yeni hasta kartı bilgilerini MERNİS'ten getirebilmemiz
 * lazım"): YENİ kartta da. Getir kimlik nodan ad / soyad / doğum / cinsiyet / anne-baba adı /
 * doğum yerini doldurur (kanal sunucuda: KPS → SGK → benzetim); Doğrula elle girileni NVİ'ye
 * denetletir. Salt okunur kartta yok.
 */
function HastaKimlikAraclari({ b }: { b: KartAracBaglami }) {
  const { yetki: oturumYetki } = useOturum();
  const { deger, id, setHata } = b;
  const [mernisYuk, setMernisYuk] = useState(false);

  /** MERNİS'TEN GETİR (19.10.2026): kart alanları + özlük (doğum, cinsiyet, anne / baba adı, doğum yeri). */
  const mernisGetir = async () => {
    const tc = String(deger.vkno ?? '').trim();
    if (!/^\d{11}$/.test(tc)) { setHata(c('Önce 11 haneli kimlik no girin.')); return }
    setMernisYuk(true); setHata(null);
    try {
      const k = await api.mernisGetir(tc);
      b.alanDegistir('ad', k.ad); b.alanDegistir('soyad', k.soyad);
      b.setDetaylar(t => {
        const d = t.ozluk ?? bosDetay();
        const s0 = d.guncel[0] ?? {};
        const dolu = (v: string | null | undefined, eski: unknown) => (v ? v : eski) as Satir[string];
        const yeni = { ...s0, dogumTarihi: dolu(k.dogumTarihi, s0.dogumTarihi), cinsiyet: dolu(k.cinsiyet, s0.cinsiyet),
                       babaAdi: dolu(k.babaAdi, s0.babaAdi), anaAdi: dolu(k.anaAdi, s0.anaAdi),
                       dogumYeri: dolu(k.dogumYeri, s0.dogumYeri) };
        return { ...t, ozluk: { ...d, guncel: [yeni, ...d.guncel.slice(1)] } };
      });
      const sgkNotu = k.kanal === 'sgk' ? ' ' + c('SGK anne / baba adı ve doğum yerini vermez - bunları elle girin.') : '';
      await bilgiMesaji((k.simulasyon
        ? `${c('SİMÜLASYON verisi getirildi')} (${k.aciklama}) - ${c('gerçek kişi değildir. Kaydetmeden önce kontrol edin.')}`
        : `${k.aciklama}: ${c('kimlik bilgileri getirildi. Kaydetmeden önce kontrol edin.')}`) + sgkNotu);
    } catch (h) { setHata(hataMetni(h)) } finally { setMernisYuk(false) }
  };
  /** MÜSTEHAKLIK SORGUSU (MEDULA): kayıtlı hastada; sonuç mesajla. */
  const mustehaklikSorgula = async () => {
    if (typeof id !== 'number') return;
    setMernisYuk(true); setHata(null);
    try {
      const s = await api.medulaMustehaklik({ hastaId: id });
      const y = (s.yanit ?? {}) as Record<string, unknown>;
      await bilgiMesaji(s.bekliyor ? c('SGK şu an yanıt vermiyor - sorgu kuyrukta, MEDULA ekranından izlenebilir.')
        : s.kabul ? `✔ ${c('Müstehak')}${y.sigortaTuru ? ` · ${y.sigortaTuru}` : ''}${y.kapsam ? ` · ${y.kapsam}` : ''}${y.yakinlik ? ` · ${y.yakinlik}` : ''}`
        : `✖ ${s.mesaj} (${s.kod})`);
    } catch (h) { setHata(hataMetni(h)) } finally { setMernisYuk(false) }
  };
  /** KİMLİĞİ DOĞRULA (NVİ herkese açık servis): kimlik no + ad + soyad + doğum yılı eşleşiyor mu. */
  const mernisDogrula = async () => {
    const tc = String(deger.vkno ?? '').trim();
    const yil = Number(String((b.detaylar.ozluk?.guncel[0]?.dogumTarihi as string | undefined) ?? '').slice(0, 4));
    if (!/^\d{11}$/.test(tc) || !String(deger.ad ?? '').trim() || !String(deger.soyad ?? '').trim() || !yil) {
      setHata(c('Doğrulama için kimlik no, ad, soyad ve doğum tarihi gerekli.')); return
    }
    setMernisYuk(true); setHata(null);
    try {
      const s = await api.mernisDogrula({ kimlikNo: tc, ad: String(deger.ad), soyad: String(deger.soyad), dogumYili: yil });
      await bilgiMesaji(s.ulasilamadi ? c('NVİ doğrulama servisine şu an ulaşılamadı - daha sonra yeniden deneyin.')
        : s.dogru ? c('✔ Kimlik bilgileri NVİ kayıtlarıyla uyuşuyor.')
        : c('✖ Kimlik bilgileri NVİ kayıtlarıyla UYUŞMUYOR - kimlik no, ad, soyad ve doğum yılını kontrol edin.'));
    } catch (h) { setHata(hataMetni(h)) } finally { setMernisYuk(false) }
  };

  return (
    <>
      {!b.salt && (
        <>
          <button className="d" type="button" disabled={mernisYuk}
                  title={c('Kimlik nodan ad, soyad, doğum tarihi / yeri, cinsiyet ve anne / baba adını getirir')}
                  onClick={() => void mernisGetir()}>
            🆔 {mernisYuk ? c('Getiriliyor…') : c('MERNİS\'ten getir')}
          </button>
          <button className="d" type="button" disabled={mernisYuk}
                  title={c('Kimlik no, ad, soyad ve doğum yılını NVİ kayıtlarıyla doğrular')}
                  onClick={() => void mernisDogrula()}>
            ✔ {c('Kimliği doğrula')}
          </button>
        </>
      )}
      {!b.yeniMi && (
        <>
          {/* MÜSTEHAKLIK (19.10.2026): MEDULA kapısı - yetki medula.provizyon Gör (sunucuda da). */}
          {oturumYetki('medula.provizyon', 'gor') && (
            <button className="d" type="button" disabled={mernisYuk}
                    title={c('SGK provizyon / müstehaklık sorgusu')}
                    onClick={() => void mustehaklikSorgula()}>
              Provizyon/Müstehaklık Sorgula
            </button>
          )}
          {oturumYetki('belge', 'ekle') && (
            <button className="d yesil" type="button" onClick={() => b.basvuruAc()}>{c('＋ Yeni Başvuru')}</button>
          )}
        </>
      )}
    </>
  );
}

/*
 * Cek/senede ozel: YON (alinan / verilen) arac cubugunda, Kaydet'in
 * saginda (kullanici). Tek secimlik ve kagidin tum anlamini
 * belirleyen alan - kimlik seridinde yer kaplamasin diye buraya
 * alindi; karttaki alan Gizli, deger buradan yazilir.
 */
function CekSenetYonu({ b }: { b: KartAracBaglami }) {
  if (!b.meta.alanlar.some(a => a.ad === 'yon')) return null;
  return (
    <label className="satir-ici" style={{ fontSize: 13, gap: 8 }}
           title="Alınan: müşteriden geldi · Verilen: tedarikçiye verildi">
      Yön
      {/* Arac cubugundaki tek secim - kutu ve yazi biraz daha buyuk
          (kullanici): kagidin yonunu belirleyen alan goze carpsin. */}
      <select value={String(b.deger.yon ?? 1)} disabled={b.salt}
              style={{ width: 150, height: 28, fontSize: 13 }}
              onChange={e => b.setDeger(d => ({ ...d, yon: Number(e.target.value) }))}>
        <option value={1}>{c('Alınan')}</option>
        <option value={2}>{c('Verilen')}</option>
      </select>
    </label>
  );
}

/*
 * ADAY HASTA (266): durum arac cubugunda ROZET - Kaydet ile Kapat
 * arasinda (kullanici). Aday yesil degil MAVI: henuz gercek hasta
 * degil, basvuruya donusunce Aktif olur.
 */
function AdayDurumRozeti({ b }: { b: KartAracBaglami }) {
  const durum = Number(b.deger.durum);
  return (
    <span className={`rozet ${durum === 1 ? 'ok'
                      : durum === 2 ? 'mavi'
                      : durum === 3 ? 'hata' : durum === 5 ? 'uyari' : 'gri'}`}
          style={{ alignSelf: 'center' }}>
      {b.meta.alanlar.find(a => a.ad === 'durum')?.kodlar?.[String(b.deger.durum ?? '')]
       ?? 'Aday'}
    </span>
  );
}

/*
 * RANDEVU akis dugmeleri (mockup): durum comboyla degil bu
 * dugmelerle degisir. Kaydet'e basilinca yazilir - kart
 * standardindan sapmamak icin ayri bir istek yapilmaz.
 * Ertele (1119) ve Tekrarla pencereleri de burada (portal - araç çubuğunda durmaları çizimi etkilemez).
 */
function RandevuKartAraclari({ b }: { b: KartAracBaglami }) {
  const { deger, yeniMi, id, kaydedilmemisDegisiklikVar } = b;
  /** Randevu kartında Ertele penceresi (1119). */
  const [erteleAcik, setErteleAcik] = useState(false);
  /** Randevu kartında Tekrarla (seri randevu) penceresi. */
  const [tekrarAcik, setTekrarAcik] = useState(false);
  return (
    <>
      {/* Renkler listedekiyle aynı (kullanıcı 16.10.2026): Geldi yeşil, Gelmedi kırmızı. */}
      <button className="d onay" disabled={Number(deger.durum) === 2}
              onClick={() => b.alanDegistir('durum', '2')}>✔ Geldi İşaretle</button>
      <button className="d ret" disabled={Number(deger.durum) === 3}
              onClick={() => b.alanDegistir('durum', '3')}>{c('✖ Gelmedi')}</button>
      <button className="d" disabled={Number(deger.durum) === 4}
              onClick={() => b.alanDegistir('durum', '4')}>{c('⊘ İptal')}</button>
      {/* GERİ AL (17.10.2026): yanlış Geldi / Gelmedi / İptal -> Planlandı (Kaydet'le yazılır).
          Başvuruya dönüşmüş ya da ertelenmiş randevuda yok. */}
      {[2, 3, 4].includes(Number(deger.durum)) && (
        <button className="d" disabled={!!deger.belgeId}
                title={deger.belgeId ? c('Randevu başvuruya dönüşmüş - önce başvuruyu iptal edin.') : c('Durumu Planlandı yap')}
                onClick={() => b.alanDegistir('durum', '1')}>{c('↩ Geri Al')}</button>
      )}
      {/* ERTELE (1119): kayıtlı, planlanmış randevu; kaydedilmemiş değişiklik varken kapalı. */}
      {!yeniMi && (
        <button className="d" disabled={Number(deger.durum) !== 1 || kaydedilmemisDegisiklikVar}
                title={kaydedilmemisDegisiklikVar ? c('Önce değişiklikleri kaydedin.') : undefined}
                onClick={() => setErteleAcik(true)}>{c('⏭ Ertele')}</button>
      )}
      {/* TEKRARLA (kullanıcı 17.10.2026): aynı randevudan seri - gün / sayı seçilir, çakışma kontrollü. */}
      {/* Yeni kartta da (17.10.2026): pencerenin Kaydet'i önce bu randevuyu yazar. */}
      <button className="d" disabled={!yeniMi && kaydedilmemisDegisiklikVar}
              title={!yeniMi && kaydedilmemisDegisiklikVar ? c('Önce değişiklikleri kaydedin.') : undefined}
              onClick={() => {
                if (yeniMi && (!Number(deger.hastaId) || !String(deger.baslangic ?? ''))) {
                  bilgiMesaji(c('Önce hasta ve ilk randevunun tarih / saatini seçin.')); return;
                }
                setTekrarAcik(true);
              }}>{c('🔁 Tekrarla')}</button>

      {erteleAcik && id != null && (() => {
        const bas = String(deger.baslangic ?? '');
        const ad = (alan: string) => b.meta.alanlar.find(a => a.ad === alan)?.kodlar?.[String(deger[alan] ?? '')];
        return (
          <RandevuErtelePenceresi
            randevu={{
              id: Number(id), hekimId: Number(deger.hekimId) || null, hekimAdi: ad('hekimId'),
              cihazId: Number(deger.cihazId) || null, cihazAdi: ad('cihazId'),
              bolum: Number(deger.bolum) || null, sureDk: Number(deger.sureDk) || 15,
              tarih: bas.slice(0, 10), saat: bas.slice(11, 16),
            }}
            onKapat={() => setErteleAcik(false)}
            onErtelendi={yeniId => { setErteleAcik(false); b.onKaydedildi?.(yeniId); b.onKapat?.() }} />
        );
      })()}
      {tekrarAcik && (() => {
        const bas = String(deger.baslangic ?? '');
        const t = bas.slice(0, 10);
        const g = new Date(`${t}T12:00`).getDay();
        const ertesi = new Date(`${t}T12:00`); ertesi.setDate(ertesi.getDate() + 1);
        const ertesiMetin = `${ertesi.getFullYear()}-${String(ertesi.getMonth() + 1).padStart(2, '0')}-${String(ertesi.getDate()).padStart(2, '0')}`;
        return (
          <RandevuSeriPenceresi baslik={`🔁 ${c('Randevuyu Tekrarla')}`}
                                kaynak={yeniMi
                                  ? { sablon: { hastaId: Number(deger.hastaId), hekimId: Number(deger.hekimId) || null,
                                                cihazId: Number(deger.cihazId) || null, bolum: Number(deger.bolum) || null,
                                                hizmetId: Number(deger.hizmetId) || null, sureDk: Number(deger.sureDk) || 15,
                                                gonderenId: Number(deger.gonderenId) || null, tip: Number(deger.tip) || 1,
                                                kaynak: Number(deger.kaynak) || 1, aciklama: String(deger.aciklama ?? '') } }
                                  : { kaynakRandevuId: Number(id) }}
                                onceKaydet={yeniMi ? async sonra => { await b.kaydet(false, sonra) } : undefined}
                                // Sayı: YENİ kartta ilk randevu dahil toplam; KAYITLI kartta bundan sonraki tekrar
                                //   sayısı (kullanıcı 17.10.2026).
                                ilkDahil={yeniMi}
                                ilkTarih={ertesiMetin} saat={bas.slice(11, 16)} sureDk={Number(deger.sureDk) || 15}
                                adet={5} gunler={[g === 0 ? 7 : g]}
                                onKapat={() => setTekrarAcik(false)}
                                onKaydedildi={n => { if (!yeniMi) bilgiMesaji(`${n} ${c('randevu oluşturuldu.')}`) }} />
        );
      })()}
    </>
  );
}

/*
 * DOKUMAN KART ARAC CUBUGU (419, mockup dokuman_karti.html).
 * Surum/onay dongusu KARTTAN yurumeli: kullanici dosyayi acip
 * inceledikten sonra listeye donup aksiyon aramasin.
 *
 * "Yeni Surum Yukle" BURADA YOK: dosya secimi ve icerik yukleme
 * kart galerisinin isi; buraya ikinci bir yukleme yolu koymak ayni
 * dosyayi iki akistan gecirmek olurdu.
 */
function DokumanKartAraclari({ b }: { b: KartAracBaglami }) {
  const { id, deger } = b;
  return (
    <>
      <button className="d" onClick={() => void guvenli(async () => {
        // Icerik ucu KIMLIK ister; adresi yeni sekmede acmak token
        //   tasimadigi icin 401 doner - blob olarak cekilir.
        const url = await api.dokumanIcerikUrl(Number(id));
        window.open(url, '_blank');
      })}>📂 Aç / Önizle</button>

      <button className="d" onClick={() => void guvenli(async () => {
        const url = await api.dokumanIcerikUrl(Number(id));
        // DOKUMAN ADIYLA iner; ad uzantisizsa icerik tipinden
        //   tamamlanir (uzantisiz dosya acilamiyor).
        dosyaIndirUrl(url, dokumanDosyaAdi(String(deger.ad ?? ''),
                                           String(deger.contentType ?? '')), true);
      })}>{c('⬇ İndir')}</button>

      {/* ONAYA GONDERILEN SURUMDUR, dokuman degil: taslak surum yoksa
          gonderilecek bir sey de yok. */}
      {Number(deger.surumlu) === 1 && (
        <button className="d" onClick={() => void guvenli(async () => {
          const k = await api.kartOku('dokuman', Number(id));
          const taslak = (k.detaylar?.surumler ?? [])
            .find(x => Number(x.durum) === 1);
          if (!taslak) {
            bilgiMesaji('Onaya gönderilecek taslak sürüm yok. '
                      + 'Önce yeni sürüm yükleyin.');
            return;
          }
          const y = await api.dokumanOnayaGonder(Number(taslak.id));
          bilgiMesaji(y.mesaj);
        })}>{c('✔ Onaya Gönder')}</button>
      )}

      {/* PAYLASIM LINKI (424): sureli ve sayacli. Ozel nitelikli
          dokumanda ayri yetki gerekir - sunucu reddeder. */}
      <button className="d" onClick={() => void guvenli(async () => {
        const y = await api.dokumanPaylasimUret(Number(id), { gunSayisi: 30 });
        // Kod PANOYA kopyalanir: kullanicidan 32 haneli bir dizeyi
        //   ekrandan elle yazmasini beklemek gercekci degil.
        const adres = `${location.origin}/api/dokuman-paylasim/${y.kod}`;
        try { await navigator.clipboard.writeText(adres) } catch { /* yoksay */ }
        bilgiMesaji(`Paylaşım linki üretildi (30 gün):\n\n${adres}\n\n`
                  + 'Adres panoya kopyalandı.');
      })}>{c('🔗 Paylaş')}</button>

      <button className="d" onClick={() => void guvenli(async () => {
        const d = await api.dokumanDepo();
        const mb = (b: number) => (b / 1024 / 1024).toFixed(1) + ' MB';
        bilgiMesaji(`Depo kullanımı\n\nFiziksel: ${mb(d.fizikselBayt)}\n`
                  + `Mantıksal: ${mb(d.mantikselBayt)}\n`
                  + `Dedup tasarrufu: ${mb(d.tasarrufBayt)}`);
      })}>📊 Depo</button>
    </>
  );
}

/*
 * ENTEGRASYON HESABI (336-340) - mockup'taki kart arac cubugu:
 * hesap kaydedildikten sonra AYNI ekrandan sinanabilsin, kullanici
 * listeye donmek zorunda kalmasin. SKRS senkronu yalniz SKRS
 * hesabinda anlamli.
 */
function EntegrasyonKartAraclari({ b }: { b: KartAracBaglami }) {
  const { kullanici } = useOturum();
  return (
    <>
      <button className="d" onClick={() => void guvenli(async () => {
        const y = await api.entegrasyonSina(Number(b.id));
        bilgiMesaji(y.mesaj);
      })}>{c('🔌 Bağlantıyı Sına')}</button>
      {/* SKRS senkronu YALNIZ HBYS kurulumunda (345): ERP'de eski bir
          SKRS satiri duruyor olsa da dugme gosterilmez. */}
      {String(b.deger.kod ?? '') === 'SKRS' && kullanici?.urunModu === 2 && (
        <button className="d" onClick={() => void guvenli(async () => {
          if (!await onaySor('SKRS kod listeleri servisten çekilip yerel '
                             + 'listeler güncellenecek. Devam edilsin mi?')) return;
          const y = await api.skrsListeSenkron(Number(b.id));
          bilgiMesaji(y.mesaj);
        })}>{c('⟳ SKRS Listelerini Güncelle')}</button>
      )}
    </>
  );
}

/*
 * HESAP EKSTRESİ (kasa / banka / POS / kredi / kredi kartı kartı; kullanıcı 23.10.2026: "banka kartında
 * hareketler sekmesini kaldır, hatırlat butonu sağına Ekstre butonu ekle"): tek Ekstre ekranı (1158)
 * hesabın türüyle açılır. Türün veri yetkisi yoksa düğme yok (hesap-ekstre kaynağının satır kısıtı).
 */
function HesapAraclari({ hesapId, tur }: { hesapId: number; tur: string }) {
  const { yetki: oturumYetki } = useOturum();
  const git = useNavigate();
  const [devir, setDevir] = useState(false);
  const kod = ({ K: 'hesap.tanim', B: 'hesap.tanim.banka', P: 'hesap.tanim.pos', R: 'hesap.tanim.kredi', V: 'hesap.tanim.kredi_karti' } as Record<string, string>)[tur];
  if (!kod || !oturumYetki(kod, 'gor')) return null;
  return (
    <>
      <button className="d" type="button" title={c('Ekstre ekranında bu hesabın hareketleri')}
              onClick={() => git(`/ekstre?tur=hesap&id=${hesapId}`)}>📄 {c('Ekstre')}</button>
      {/* DEVİR / AÇILIŞ (1160): karttaki açılış bakiyesi alanı yerine hesabın devir hareketi. */}
      {oturumYetki('finans.devir', 'gor') && (
        <button className="d" type="button" title={c('Açılış bakiyesi (devir hareketi)')} onClick={() => setDevir(true)}>↪️ {c('Devir / Açılış')}</button>)}
      {devir && <DevirPenceresi tur="hesap" id={hesapId} onKapat={() => setDevir(false)} onKaydedildi={() => setDevir(false)} />}
    </>
  );
}

/*
 * CARİ EKSTRE (kullanıcı 23.10.2026: "müşteri kartındaki ekstre sekmeyi kaldır, onun yerine üste
 * Ekstre butonu ekle"): kartta ayrı bir ekstre yok - Kasa › Cari Ekstre listesi bu cariye süzülmüş
 * olarak açılır (sekme düzeninde kendi sekmesinde). Listeye erişimi olmayana düğme yok.
 */
function CariEkstreDugmesi({ tarafId, ad }: { tarafId: number; ad: string }) {
  const { yetki: oturumYetki } = useOturum();
  const git = useNavigate();
  if (!oturumYetki('mali_hareket', 'gor')) return null;
  return (
    <button className="d" type="button" title={`${c('Ekstre ekranında bu carinin hareketleri')} - ${ad}`}
            onClick={() => git(`/ekstre?tur=cari&id=${tarafId}`)}>📄 {c('Ekstre')}</button>
  );
}

/*
 * Cari'ye ozel: Musteri/Tedarikci rolleri hizlı erisim icin arac cubuguna,
 * Kaydet/Sil ile ayni satira, saga yanasik olarak da tasindi (Roller sekmesindeki
 * alanlarla AYNI deger - ikisi de senkron, tekrar degil).
 * Musteri/Tedarikci kutulari: ADAY ekraninda YOK (kullanici karari) -
 * aday henuz ne musteri ne tedarikci; rolu donusumde belirlenir.
 */
function CariRolKutulari({ b }: { b: KartAracBaglami }) {
  if (b.gizliAlanlar?.includes('musteri') || !b.meta.alanlar.some(a => a.ad === 'musteri')) return null;
  return (
    <span style={{ marginLeft: 'auto', display: 'flex', gap: 12, alignItems: 'center' }}>
      <label className="satir-ici">
        <input
          type="checkbox"
          checked={Boolean(b.deger.musteri)}
          disabled={b.salt}
          onChange={e => b.setDeger(d => ({ ...d, musteri: e.target.checked }))}
        />
        Müşteri
      </label>
      <label className="satir-ici">
        <input
          type="checkbox"
          checked={Boolean(b.deger.tedarikci)}
          disabled={b.salt}
          onChange={e => b.setDeger(d => ({ ...d, tedarikci: e.target.checked }))}
        />
        Tedarikçi
      </label>
    </span>
  );
}
