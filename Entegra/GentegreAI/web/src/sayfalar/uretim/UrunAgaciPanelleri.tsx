import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni, type ListeSatiri } from '../../api/sozlesme';
import type { AgacSurumu } from '../../api/uclar/uretim';
import { fisDurumAdi, type FisIstegi, type FisSatiri } from '../../api/uclar/uretimFisi';
import { LISTE_TAZELE_OLAYI } from '../../bilesenler/sekmeBaglami';
import { Modal } from '../../bilesenler/Modal';
import { eksikMi, enCokUretilir } from './uretimFisiYardimci';
import { bugunIso } from '../../bilesenler/bicim';
import { useSekmedeAc } from '../../bilesenler/KartAdi';
import { para, sayi, tarihSaat } from '../../bilesenler/bicim';
import { useUretimSeviyesi } from '../../bilesenler/useUretimSeviyesi';
import { useOturum } from '../../kimlik/OturumBaglami';
import { ImzaPenceresi } from '../../bilesenler/ImzaPenceresi';
import { mesaj } from '../../bilesenler/mesaj';
import { c } from '../../dil/ceviri';
import { UEP_STILI } from './uretimStil';

/**
 * ÜRÜN AĞACI (REÇETE) KARTI EK PARÇALARI (1258, mockup urun_agaci_karti_v2.html): onay şeridi (denetimli), araç
 * düğmeleri (seviyeye göre), Üretimler sekmesi (bu reçeteden açılan emirler + kesilen fişler), Sürümler / Değişiklik
 * Geçmişi (ECN) sekmesi. Generic karta kartEklentileri üzerinden eklenir; kural sunucuda, ekran gösterir.
 */
type Deger = Record<string, unknown>;
/** ISO tarih → gg.aa.yyyy (saat atılır). */
const tarih = (v: string) => { const m = v.slice(0, 10); return /^\d{4}-\d{2}-\d{2}$/.test(m) ? m.split('-').reverse().join('.') : v };
const EMIR_DURUM: Record<number, string> = { 0: 'İptal', 1: 'Taslak', 2: 'Onaylı', 3: 'Serbest', 4: 'Üretimde', 5: 'Kısmi', 6: 'Tamamlandı', 7: 'Kapatıldı' };

/**
 * ONAY ROZETLERİ (denetimli) - araç çubuğunda Hatırlat'ın sağında: Taslak › Onayda › Onaylı › Yürürlükte › Kilitli.
 * Geçilen adım yeşil, şimdiki sarı, kalan gri; ayrıntı (kim, ne zaman, ECN, açık emir) rozet ipucunda. Eski şerit bölgesi
 * kaldırıldı (kullanıcı 04.11.2026).
 */
export function ReceteOnayRozetleri({ agacId, tazele }: { agacId: number; tazele: number }) {
  const [s, setS] = useState<AgacSurumu | null>(null);
  useEffect(() => { void api.uretimAgacSurumler(agacId).then(y => setS(y.surumler.find(x => x.id === agacId) ?? null)).catch(() => setS(null)) }, [agacId, tazele]);
  if (!s) return null;
  const onay = s.onayDurum;
  const simdi = onay === 0 ? 0 : onay === 1 ? 1 : onay === 2 ? 3 : 4;
  const adimlar = [
    { ad: 'Taslak', ipucu: [s.hazirlayan, s.degisme ? tarih(s.degisme) : ''].filter(Boolean).join(' · ') },
    { ad: 'Onayda', ipucu: s.onayaGonderme ? `${c('gönderildi')} ${tarih(s.onayaGonderme)}` : '' },
    { ad: 'Onaylı', ipucu: [s.onaylayan ? `${s.onaylayan} ✍` : '', s.onayTarihi ? tarih(s.onayTarihi) : '', s.ecnNo].filter(Boolean).join(' · ') },
    { ad: 'Yürürlükte', ipucu: [s.yururluk ? tarih(s.yururluk) : '', s.acikEmir ? `${s.acikEmir} ${c('açık emir')}` : ''].filter(Boolean).join(' · ') },
    { ad: 'Kilitli', ipucu: c('yeni sürüm onaylanınca') },
  ];
  const kilit = onay >= 2 ? c('Onaylı reçetenin bileşen / rota / kontrol listesi ve kimlik alanları değiştirilemez - değişiklik "Yeni Sürüm" ile.') : '';
  return (
    // KISA: araç çubuğu taşmasın - rozette yalnız adım adı (şimdikinde ECN), ayrıntı ipucunda.
    <span className="rozet-dizi" title={kilit || undefined} style={{ alignSelf: 'center', marginRight: 6 }}>
      {adimlar.map((a, i) => (
        <span key={a.ad} className={`rozet ${i < simdi ? 'ok' : i === simdi ? 'uyari' : 'gri'}`} title={a.ipucu || undefined} style={{ opacity: i > simdi ? .6 : 1 }}>
          {i === simdi && onay >= 2 ? '🔒 ' : ''}{c(a.ad)}{i === simdi && s.ecnNo ? ` · ${s.ecnNo}` : ''}
        </span>))}
    </span>
  );
}


/**
 * "ÜRET…" PENCERESİ (basit seviye, mockup ②): reçeteden TEK ADIMDA üretim fişi - adet, tarih, depo, sorumlu; malzemeler
 * reçeteden (fiş doldurma ucu), eksik uyarısı; "Üret ve Stoğa İşle" fişi gerçekleştirir (sarf çıkar, mamul girer).
 * Emir yok. Standart / denetimli seviyede fiş kartı açılır (Üretim Fişi Kes) - orada parti, lot, kalite var.
 */
export function ReceteUretPenceresi({ stokId, agacId, kod, ad, ciktiMiktar, onKapat, onBitti }: {
  stokId: number; agacId: number; kod: string; ad: string; ciktiMiktar: number; onKapat(): void; onBitti(): void;
}) {
  const [adet, setAdet] = useState(String(ciktiMiktar > 0 ? ciktiMiktar : 1));
  const [tarih, setTarih] = useState(bugunIso());
  const [depolar, setDepolar] = useState<{ id: number; ad: string }[]>([]);
  const [personel, setPersonel] = useState<{ id: number; ad: string }[]>([]);
  const [sarfDepoId, setSarfDepoId] = useState<number | null>(null);
  const [sorumluId, setSorumluId] = useState<number | null>(null);
  const [satirlar, setSatirlar] = useState<FisSatiri[]>([]);
  const [hata, setHata] = useState('');
  const [mesgul, setMesgul] = useState(false);
  const adetSayi = Number(adet.replace(',', '.')) || 0;
  useEffect(() => {
    void api.liste('depo', { sayfa: 1, boyut: 200, sirala: [{ alan: 'ad', yon: 'asc' }], filtre: { alan: 'durum', op: 'esit', deger: 1 } })
      .then(y => setDepolar(y.satirlar.map(x => ({ id: Number(x.id), ad: String(x.ad ?? '') })))).catch(() => setDepolar([]));
    void api.liste('personel', { sayfa: 1, boyut: 300, sirala: [{ alan: 'unvan', yon: 'asc' }], filtre: { alan: 'durum', op: 'esit', deger: 1 } })
      .then(y => setPersonel(y.satirlar.map(x => ({ id: Number(x.id), ad: String(x.unvan ?? '') })))).catch(() => setPersonel([]));
  }, []);
  // Malzeme önizlemesi: adet / depo değişince reçeteden yeniden doldurulur (yazmaz).
  useEffect(() => {
    if (!(adetSayi > 0)) return;
    let iptal = false;
    void api.uretimFisDoldur({ stokId, agacId, miktar: adetSayi, sarfDepoId, maliyetYontemi: 1 })
      .then(y => { if (iptal) return; setSatirlar(y.satirlar); if (sarfDepoId == null) setSarfDepoId(y.agac.sarfDepoId ?? null); setHata('') })
      .catch(h => { if (!iptal) setHata(hataMetni(h)) });
    return () => { iptal = true };
  }, [stokId, agacId, adetSayi, sarfDepoId]);
  const eksikler = satirlar.filter(eksikMi);
  const enCok = enCokUretilir(satirlar);
  const depoAdi = depolar.find(d => d.id === sarfDepoId)?.ad ?? c('depo');
  const uret = async (eksiyeIzin: boolean) => {
    if (!(adetSayi > 0)) { setHata(c('Adet sıfırdan büyük olmalı.')); return }
    if (!sarfDepoId) { setHata(c('Depo seçilmeli.')); return }
    setMesgul(true); setHata('');
    try {
      const g: FisIstegi = {
        stokId, agacId, emirId: null, miktar: adetSayi, bas: tarih ? `${tarih}T00:00` : null, bit: null,
        sarfDepoId, girisDepoId: sarfDepoId, isMerkeziId: null, sorumluId, onaylayanId: null, projeId: null, partiNo: '',
        maliyetYontemi: 1, otomatikHesap: true, aciklama: `${kod} reçetesinden`,
        satirlar: satirlar.filter(x => x.miktar > 0 || x.grup === 2).map(x => ({
          grup: x.grup, stokId: x.grup === 2 ? null : x.stokId, masrafId: null, ad: x.grup === 2 ? (x.ad || x.stokAd) : '', anaUrun: x.anaUrun,
          birimIhtiyac: x.birimIhtiyac, planMiktar: x.planMiktar, miktar: x.miktar, birim: x.birim, birimMaliyet: x.birimMaliyet,
          elleMaliyet: x.elleMaliyet, fireTuru: x.fireTuru, izlemler: x.izlemler?.length ? x.izlemler : null, aciklama: x.aciklama })),
        operasyonlar: [], kontroller: [], gerceklestir: true, eksiyeIzin, surum: null,
      };
      const y = await api.uretimFisEkle(g);
      window.dispatchEvent(new CustomEvent(LISTE_TAZELE_OLAYI, { detail: 'uretim-fisi' }));
      mesaj(y.mesaj + (y.uyarilar?.length ? '\n\n' + y.uyarilar.join('\n') : ''));
      onBitti();
    } catch (h) { setHata(hataMetni(h)) } finally { setMesgul(false) }
  };
  return (
    <Modal baslik={`🏭 ${c('Üret')} — ${kod} ${ad}`} dar enUst onKapat={onKapat}
           alt={<><span style={{ marginLeft: 'auto' }} /><button type="button" className="d" onClick={onKapat}>{c('Vazgeç')}</button>
                 <button type="button" className="d onay" disabled={mesgul || !(adetSayi > 0)} onClick={() => void uret(false)}>✔ {c('Üret ve Stoğa İşle')}</button></>}>
      <div className="alan-izgara" style={{ padding: 10, gridTemplateColumns: '1fr 1fr' }}>
        {hata && <div className="hata-kutusu" style={{ gridColumn: 'span 2' }}>{hata}</div>}
        <label className="alan"><span className="etiket zorunlu-isaret">{c('Kaç adet üretildi?')}</span>
          <input value={adet} inputMode="decimal" onChange={e => setAdet(e.target.value)} /></label>
        <label className="alan"><span className="etiket">{c('Tarih')}</span><input type="date" value={tarih} onChange={e => setTarih(e.target.value)} /></label>
        <label className="alan"><span className="etiket zorunlu-isaret">{c('Depo (sarf / giriş)')}</span>
          <select value={sarfDepoId ?? 0} onChange={e => setSarfDepoId(Number(e.target.value) || null)}>
            <option value={0}>—</option>{depolar.map(d => <option key={d.id} value={d.id}>{d.ad}</option>)}</select></label>
        <label className="alan"><span className="etiket">{c('Sorumlu')}</span>
          <select value={sorumluId ?? 0} onChange={e => setSorumluId(Number(e.target.value) || null)}>
            <option value={0}>—</option>{personel.map(d => <option key={d.id} value={d.id}>{d.ad}</option>)}</select></label>
        {eksikler.length > 0 && (
          <div className="uyari-kutusu" style={{ gridColumn: 'span 2', padding: '6px 10px', fontSize: 11.5 }}>
            ⚠ <b>{eksikler[0].stokAd}</b>: {depoAdi}'da {sayi.format(eksikler[0].depoKalan)} {eksikler[0].birimAdi} var, {sayi.format(eksikler[0].planMiktar)} {c('gerekli')}
            {eksikler.length > 1 ? ` (+${eksikler.length - 1} ${c('malzeme daha')})` : ''}. {c('Bu stokla en çok')} <b>{sayi.format(enCok ?? 0)}</b> {c('adet üretilebilir.')}
            {' '}<button type="button" className="d mini" disabled={mesgul} onClick={() => void uret(true)}>{c('Yine de üret (stok eksiye düşer)')}</button>
          </div>)}
        <div className="sl" style={{ gridColumn: 'span 2', fontSize: 11 }}>
          {satirlar.length ? `${satirlar.filter(x => x.grup === 1).length} ${c('malzeme reçeteden')}${satirlar.some(x => x.grup === 2) ? ` · ${c('işçilik / gider reçeteden')}` : ''} · ${c('Kaydet = üretim fişi gerçekleşir: sarf çıkar, mamul girer, maliyet hesaplanır. Emir yoktur.')}` : c('Malzemeler reçeteden hesaplanıyor…')}
        </div>
      </div>
    </Modal>
  );
}

/**
 * PASİFE AL / ONAYA GÖNDER / ONAYLA / ÜRET pencereleri (liste üst paneli ve kart araç çubuğu ortak). Pasife alma:
 * denetimlide gerekçe zorunlu, onaylı reçetede e-imza. Onay: e-imza (parola), karar onayla / reddet; onayda ECN no + yürürlük.
 */
export function ReceteIslemPenceresi({ islem, id, kod, onayDurum, satir, onKapat, onBitti }: {
  islem: 'pasif' | 'onaya-gonder' | 'onayla' | 'uret'; id: number; kod: string; onayDurum: number; satir?: Record<string, unknown>; onKapat(): void; onBitti(): void;
}) {
  const sv = useUretimSeviyesi();
  if (islem === 'uret') return (
    <ReceteUretPenceresi stokId={Number(satir?.stokId ?? 0)} agacId={id} kod={kod} ad={String(satir?.ad ?? '')}
                         ciktiMiktar={Number(satir?.ciktiMiktar ?? 1)} onKapat={onKapat} onBitti={onBitti} />);
  if (islem === 'pasif') return (
    <ImzaPenceresi baslik={`⊘ ${c('Reçeteyi pasife al')} — ${kod}`} parolaIster={sv.denetimli && onayDurum >= 2} gerekceZorunlu={sv.denetimli}
      onaylaMetni={() => `⊘ ${c('Pasife al')}`}
      aciklama={c('Reçete silinmez; pasife alınır, varsayılan olmaktan çıkar. Açık emirler kendi sürümüyle biter.')}
      onKapat={onKapat}
      onImzala={async (gerekce, parola) => { const y = await api.uretimAgacPasif(id, gerekce, parola || undefined); mesaj(y.mesaj); onBitti() }} />);
  if (islem === 'onaya-gonder') return (
    <ImzaPenceresi baslik={`✍ ${c('Onaya gönder')} — ${kod}`} parolaIster={false} gerekceZorunlu={false}
      onaylaMetni={() => `✍ ${c('Onaya gönder')}`}
      aciklama={c('Taslak reçete onaya gider; onaylayan (uretim.recete.onay yetkisi, sizden farklı kişi) e-imza ile onaylar, ECN no ve yürürlük tarihi verilir.')}
      onKapat={onKapat}
      onImzala={async gerekce => { const y = await api.uretimAgacOnayaGonder(id, gerekce); mesaj(y.mesaj); onBitti() }} />);
  return (
    <ImzaPenceresi baslik={`✔ ${c('Reçete onayı')} — ${kod}`} parolaIster gerekceZorunlu={false}
      kararlar={[{ deger: 1, ad: c('Onayla - yürürlüğe al') }, { deger: 2, ad: c('Reddet - taslağa döndür'), tehlike: true }]}
      onaylaMetni={k => k === 1 ? `✍ ${c('İmzala ve onayla')}` : `✖ ${c('İmzala ve reddet')}`}
      aciklama={c('İmza kaydı: ad, zaman, anlam, gerekçe (21 CFR Part 11 §11.50). Onaylı reçetenin bileşen / rota / kontrol listesi kilitlenir; değişiklik yeni sürümle.')}
      onKapat={onKapat}
      onImzala={async (gerekce, parola, karar) => { const y = await api.uretimAgacOnayla(id, karar === 2 ? 2 : 1, gerekce, parola); mesaj(y.mesaj); onBitti() }} />);
}

/** Başlık eki: "RC-0001 v3" + onay / durum rozeti (mockup başlık satırı). */
export function ReceteBaslikEk({ deger }: { deger: Deger }) {
  const sv = useUretimSeviyesi();
  const onay = Number(deger.onayDurum ?? 0);
  const pasif = Number(deger.durum ?? 0) !== 0;
  return (
    <span className="rozet-dizi" style={{ marginLeft: 8 }}>
      <span className="rozet mavi">{String(deger.kod ?? '')}{sv.standartVe && deger.agacSurum != null ? ` v${String(deger.agacSurum)}` : ''}</span>
      {pasif ? <span className="rozet gri">{c('Pasif')}</span>
        : sv.denetimli ? <span className={`rozet ${onay === 2 ? 'ok' : onay === 1 ? 'uyari' : onay === 3 ? 'gri' : 'gri'}`}>{c(onay === 2 ? 'Onaylı' : onay === 1 ? 'Onayda' : onay === 3 ? 'Kilitli' : 'Taslak')}</span>
        : Number(deger.varsayilan ?? 0) === 1 && sv.standartVe ? <span className="rozet ok">{c('Varsayılan')}</span> : null}
    </span>
  );
}

/**
 * Bileşenler sekmesinin altındaki özet kartları (mockup .ozet): Malzeme · İşçilik · Toplam · Tavsiye satış · stok
 * hazırlığı / bugün üretilebilir. Maliyet alanları karttan, üretilebilir liste kaynağından (fn_urun_agaci_uretilebilir).
 */
export function ReceteMaliyetOzeti({ agacId, deger, tazele }: { agacId: number; deger: Deger; tazele: number }) {
  const sv = useUretimSeviyesi();
  const [uretilebilir, setUretilebilir] = useState<number | null>(null);
  useEffect(() => {
    void api.uretimAgacSurumler(agacId).then(y => setUretilebilir(y.surumler.find(x => x.id === agacId)?.uretilebilir ?? null)).catch(() => setUretilebilir(null));
  }, [agacId, tazele]);
  const n = (k: string) => Number(deger[k] ?? 0);
  const katsayi = n('tavsiyeSatisKatsayi');
  const kutu = (deger: string, ad: string, ek?: string, sinif = '') => (
    <span key={ad} className={`pl-k${sinif ? ' ' + sinif : ''}`} style={{ cursor: 'default' }}><b>{deger}</b><span>{ad}{ek ? ` · ${ek}` : ''}</span></span>);
  return (
    <div className="pl-kpi ml-kpi" style={{ padding: '8px 10px' }}>
      {kutu(para.format(n('maliyetMalzeme')), c('Malzeme'), c('₺ / çıktı'))}
      {kutu(para.format(n('maliyetIscilik')), c(sv.basit ? 'İşçilik / gider' : 'İşçilik (rota)'))}
      {sv.standartVe && n('maliyetGug') > 0 && kutu(para.format(n('maliyetGug')), c('Genel üretim gideri'))}
      {kutu(para.format(n('maliyetToplam')), c('Toplam maliyet'), deger.maliyetTarih ? `${c('son hesap')} ${tarih(String(deger.maliyetTarih))}` : c('hesaplanmadı'), n('maliyetToplam') > 0 ? '' : 'uyari')}
      {sv.standartVe && katsayi > 0 && kutu(para.format(n('maliyetToplam') * katsayi), c('Tavsiye satış'), `× ${sayi.format(katsayi)}`)}
      {uretilebilir != null && kutu(sayi.format(uretilebilir), c(sv.basit ? 'Bugün üretilebilir' : 'Stokla üretilebilir'), c('mevcut stokla'), uretilebilir > 0 ? '' : 'uyari')}
    </div>
  );
}

/** Araç çubuğu düğmeleri (seviyeye göre): Üret… / Üretim Emri Aç / Fiş Kes / Kopyala / Yeni Sürüm / Onaya Gönder / Onayla / Pasife Al. */
export function ReceteKartAraclari({ deger, aksiyon, yetki, onDegisti }: {
  deger: Deger; aksiyon(kod: string, satir?: Record<string, unknown> | null): void | Promise<void>;
  yetki(kod: string, islem?: 'gor' | 'ekle' | 'degistir' | 'sil'): boolean; onDegisti(): void;
}) {
  const sv = useUretimSeviyesi();
  const { aksiyonVar } = useOturum();
  // Pencereli işlemler kartta YEREL açılır: liste üst paneli (olay dinleyicisi) kart kendi sekmesindeyken yok.
  const [pencere, setPencere] = useState<'pasif' | 'onaya-gonder' | 'onayla' | 'uret' | null>(null);
  const PENCERELI = ['urun-agaci.pasif', 'urun-agaci.onaya-gonder', 'urun-agaci.onayla', 'urun-agaci.uret'];
  const satir = { id: deger.id, stokId: deger.stokId, kod: deger.kod, ciktiMiktar: deger.ciktiMiktar, onayDurum: deger.onayDurum };
  const onay = Number(deger.onayDurum ?? 0);
  const pasif = Number(deger.durum ?? 0) !== 0;
  const d = (kod: string, ad: string, sinif = '', goster = true, baslik?: string) => goster
    ? <button key={kod} type="button" className={`d ${sinif}`} title={baslik}
              onClick={() => PENCERELI.includes(kod) ? setPencere(kod.slice('urun-agaci.'.length) as typeof pencere) : void aksiyon(kod, satir)}>{ad}</button> : null;
  return (
    <>
      {pencere && <ReceteIslemPenceresi islem={pencere} id={Number(deger.id)} kod={String(deger.kod ?? '')} onayDurum={onay} satir={deger}
                                        onKapat={() => setPencere(null)} onBitti={() => { setPencere(null); onDegisti() }} />}
      {sv.basit && d('urun-agaci.uret', `🏭 ${c('Üret…')}`, 'onay', yetki('uretim.fis', 'ekle') && !pasif, c('Bu reçeteden üretim fişi keser: adet sor, malzemeler reçeteden, stoğa işle'))}
      {sv.standartVe && d('urun-agaci.emir-ac', `📋 ${c('Üretim Emri Aç')}`, 'onay', yetki('uretim', 'ekle') && !pasif)}
      {sv.standartVe && d('urun-agaci.fis-kes', `🧾 ${c('Üretim Fişi Kes')}`, '', yetki('uretim.fis', 'ekle') && !pasif)}
      {sv.basit && d('urun-agaci.kopyala', `⧉ ${c('Kopyala')}`, '', yetki('uretim', 'ekle'))}
      {sv.standartVe && d('urun-agaci.yeni-surum', `⧉ ${c('Yeni Sürüm')}`, '', yetki('uretim', 'ekle'))}
      {sv.standartVe && d('urun-agaci.maliyet', `🧮 ${c('Maliyet Hesapla')}`, '', yetki('uretim', 'degistir'))}
      {sv.standartVe && d('urun-agaci.nerede', `🔎 ${c('Nerede Kullanılıyor')}`)}
      {sv.denetimli && onay === 0 && d('urun-agaci.onaya-gonder', `✍ ${c('Onaya Gönder…')}`, 'mor', yetki('uretim', 'degistir') && !pasif)}
      {sv.denetimli && onay === 1 && d('urun-agaci.onayla', `✔ ${c('Onayla / Reddet…')}`, 'onay', aksiyonVar('uretim.recete.onay'))}
      {sv.denetimli && d('urun-agaci.pasif', `⊘ ${c('Pasife Al…')}`, '', yetki('uretim', 'degistir') && !pasif)}
    </>
  );
}

/**
 * MALİYET SEKMESİ (mockup ① Maliyet): kalem · tutar · pay · açıklama + Hesapla (GÜG % sorar, aksiyon urun-agaci.maliyet).
 * Rakamlar kartın maliyet alanları (fn_urun_agaci_maliyet sonucu, tarihli); yeniden hesap kartı tazeler.
 */
export function ReceteMaliyetSekmesi({ agacId, deger, aksiyon }: {
  agacId: number; deger: Deger; aksiyon(kod: string, satir?: Record<string, unknown> | null): void | Promise<void>;
}) {
  const sv = useUretimSeviyesi();
  const n = (k: string) => Number(deger[k] ?? 0);
  const malzeme = n('maliyetMalzeme'), iscilik = n('maliyetIscilik'), gug = n('maliyetGug'), toplam = n('maliyetToplam');
  const pay = (x: number) => toplam > 0 ? `%${sayi.format(Math.round(x * 100 / toplam))}` : '';
  const katsayi = n('tavsiyeSatisKatsayi');
  return (
    <div style={{ padding: 10 }}>
      <style>{UEP_STILI}</style>
      <div style={{ display: 'flex', gap: 6, alignItems: 'center', marginBottom: 8 }}>
        {sv.standartVe && <button type="button" className="d onay" onClick={() => void aksiyon('urun-agaci.maliyet', { id: agacId })}>🧮 {c('Hesapla')}</button>}
        <span className="sl" style={{ fontSize: 11 }}>{c('Fiyat kaynağı: son alış / ağırlıklı ortalama (fn_uretim_stok_son_maliyeti); yarı mamul alt reçetenin kendi maliyetinden.')}</span>
        <span className="sl" style={{ marginLeft: 'auto', fontSize: 11 }}>{deger.maliyetTarih ? `${c('son hesap')} ${tarihSaat(String(deger.maliyetTarih))}` : c('henüz hesaplanmadı')}</span>
      </div>
      <table className="uep-dg">
        <thead><tr><th>{c('Kalem')}</th><th className="sg">{c('Tutar')}</th><th className="sg">{c('Pay')}</th><th>{c('Açıklama')}</th></tr></thead>
        <tbody>
          <tr><td>{c('Malzeme')}</td><td className="sg">{para.format(malzeme)}</td><td className="sg">{pay(malzeme)}</td><td className="sl">{c('bileşen satırları, fire dahil; yarı mamul alt reçeteden')}</td></tr>
          <tr><td>{c(sv.basit ? 'İşçilik / gider' : 'İşçilik')}</td><td className="sg">{para.format(iscilik)}</td><td className="sg">{pay(iscilik)}</td><td className="sl">{c(sv.basit ? 'reçete sabiti' : 'operasyonlar × iş merkezi saat ücreti')}</td></tr>
          {sv.standartVe && <tr><td>{c('Genel üretim gideri')}</td><td className="sg">{para.format(gug)}</td><td className="sg">{pay(gug)}</td><td className="sl">{c('Hesapla penceresinde sorulan GÜG % - ay sonu kesinleştirme fişe yazar')}</td></tr>}
          <tr className="top"><td>{c('Toplam birim maliyet')}</td><td className="sg"><b>{para.format(toplam)}</b></td><td className="sg" /><td className="sl">{c('plan / fiyat içindir; üretim fişi gerçek sarftan hesaplar (IAS 2)')}</td></tr>
          {sv.standartVe && katsayi > 0 && <tr><td>{c('Tavsiye satış')} (× {sayi.format(katsayi)})</td><td className="sg">{para.format(toplam * katsayi)}</td><td className="sg" /><td className="sl">{c('fiyat listesine öneri olarak yazılabilir')}</td></tr>}
        </tbody>
      </table>
    </div>
  );
}

/** Üretimler: bu reçeteden açılan emirler (standart+) ve kesilen fişler. */
export function ReceteUretimlerSekmesi({ agacId, tazele }: { agacId: number; tazele: number }) {
  const sv = useUretimSeviyesi();
  const ac = useSekmedeAc();
  const [emirler, setEmirler] = useState<ListeSatiri[] | null>(null);
  const [fisler, setFisler] = useState<ListeSatiri[] | null>(null);
  const [hata, setHata] = useState('');
  useEffect(() => {
    const f = { alan: 'agacId', op: 'esit' as const, deger: agacId };
    void api.liste('uretim-fisi', { sayfa: 1, boyut: 100, filtre: f }).then(y => setFisler(y.satirlar)).catch(h => setHata(hataMetni(h)));
    if (sv.standartVe) void api.liste('uretim-emri', { sayfa: 1, boyut: 100, filtre: f }).then(y => setEmirler(y.satirlar)).catch(h => setHata(hataMetni(h)));
  }, [agacId, tazele, sv.standartVe]);
  const emirlerG = sv.standartVe ? emirler : [];     // basit: emir yok, sekme yalnız fişleri çizer
  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!fisler || !emirlerG) return <div className="yukleniyor">{c('Yükleniyor…')}</div>;
  const uretilen = fisler.filter(f => Number(f.durum) !== 0).reduce((a, f) => a + Number(f.uretilen ?? 0), 0);
  return (
    <div style={{ padding: 10 }}>
      <style>{UEP_STILI}</style>
      <p className="uep-not">{c('Reçetenin plan maliyeti (karttaki) ile fişlerdeki gerçek maliyet arasındaki sapma reçeteyi güncelleme sinyalidir.')}</p>
      {sv.standartVe && (
        <>
          <h6 style={{ margin: '0 0 4px' }}>📋 {c('Üretim emirleri')} ({emirlerG.length})</h6>
          <table className="uep-dg">
            <thead><tr><th>{c('Emir')}</th><th>{c('Tarih')}</th><th className="or">{c('Sürüm')}</th><th className="sg">{c('Plan')}</th><th className="sg">{c('Üretilen')}</th><th>{c('Termin')}</th><th>{c('Durum')}</th></tr></thead>
            <tbody>
              {emirlerG.map(e => (
                <tr key={String(e.id)}>
                  <td><button type="button" className="bag" onClick={() => ac(`/uretim-emri/${e.id}`)}>{String(e.no ?? '')} ↗</button></td>
                  <td>{e.planBas ? tarih(String(e.planBas)) : ''}</td><td className="or">v{String(e.agacSurum ?? '')}</td>
                  <td className="sg">{sayi.format(Number(e.adet ?? 0))}</td><td className="sg">{sayi.format(Number(e.uretilenAdet ?? 0))}</td>
                  <td>{e.termin ? tarih(String(e.termin)) : ''}</td>
                  <td><span className={`rz ${[6, 7].includes(Number(e.durum)) ? 'ok' : Number(e.durum) === 0 ? 'hata' : 'gri'}`}>{String(e.durumAdi ?? EMIR_DURUM[Number(e.durum)] ?? '')}</span></td>
                </tr>))}
              {emirlerG.length === 0 && <tr><td colSpan={7} className="sl bos">{c('Bu reçeteden açılmış üretim emri yok.')}</td></tr>}
            </tbody>
          </table>
        </>)}
      <h6 style={{ margin: '10px 0 4px' }}>🧾 {c('Üretim fişleri')} ({fisler.length})</h6>
      <table className="uep-dg">
        <thead><tr><th>{c('Fiş')}</th><th>{c('Tarih')}</th><th>{c('Emir')}</th><th className="sg">{c('Üretilen')}</th><th className="sg">{c('Birim maliyet')}</th><th className="sg">{c('Toplam')}</th>{sv.denetimli && <th className="or">{c('Kalite')}</th>}<th>{c('Durum')}</th></tr></thead>
        <tbody>
          {fisler.map(f => (
            <tr key={String(f.id)} className={Number(f.durum) === 0 ? 'ters' : ''}>
              <td><button type="button" className="bag" onClick={() => ac(`/uretim-fisi/${f.id}`)}>{String(f.no ?? '')} ↗</button></td>
              <td>{f.bas ? tarihSaat(String(f.bas)) : ''}</td><td>{String(f.emirNo ?? '') || <span className="sl">—</span>}</td>
              <td className="sg">{sayi.format(Number(f.uretilen ?? 0))}</td><td className="sg">{para.format(Number(f.birimMaliyet ?? 0))}</td><td className="sg">{para.format(Number(f.toplam ?? 0))}</td>
              {sv.denetimli && <td className="or">{String(f.kalite ?? '')}</td>}
              <td><span className={`rz ${Number(f.durum) === 3 ? 'ok' : Number(f.durum) === 2 ? (sv.denetimli ? 'uy' : 'ok') : Number(f.durum) === 0 || Number(f.durum) === 4 ? 'hata' : 'gri'}`}>{fisDurumAdi(Number(f.durum), sv.denetimli ? 'denetimli' : '')}</span></td>
            </tr>))}
          {fisler.length === 0 && <tr><td colSpan={8} className="sl bos">{c('Bu reçeteden kesilmiş üretim fişi yok.')}</td></tr>}
          {fisler.length > 0 && <tr className="top"><td colSpan={3}>{c('Toplam üretilen')}</td><td className="sg">{sayi.format(uretilen)}</td><td colSpan={4} /></tr>}
        </tbody>
      </table>
    </div>
  );
}

/** Sürümler (standart+) ve Değişiklik Geçmişi / ECN (denetimli) - aynı veri, iki görünüm. */
export function ReceteSurumlerSekmesi({ agacId, tazele, git, ecn }: { agacId: number; tazele: number; git(yol: string): void; ecn: boolean }) {
  const [surumler, setSurumler] = useState<AgacSurumu[] | null>(null);
  const [hata, setHata] = useState('');
  useEffect(() => { void api.uretimAgacSurumler(agacId).then(y => setSurumler(y.surumler)).catch(h => setHata(hataMetni(h))) }, [agacId, tazele]);
  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!surumler) return <div className="yukleniyor">{c('Yükleniyor…')}</div>;
  const rozet = (s: AgacSurumu) => s.durum !== 0 ? <span className="rz gri">{c('Pasif')}</span>
    : s.onayDurum === 2 ? <span className="rz ok">{c('Onaylı')}{s.varsayilan ? ` · ${c('varsayılan')}` : ''}</span>
    : s.onayDurum === 3 ? <span className="rz gri">{c('Kilitli')}</span>
    : s.onayDurum === 1 ? <span className="rz uy">{c('Onayda')}</span>
    : s.varsayilan ? <span className="rz ok">{c('Aktif · varsayılan')}</span> : <span className="rz gri">{c(ecn ? 'Taslak' : 'Eski sürüm')}</span>;
  return (
    <div style={{ padding: 10 }}>
      <style>{UEP_STILI}</style>
      {ecn
        ? <p className="uep-not">{c('Değişiklik günlüğü: reçete sürümü + onay imzasının birleşik görünümü (izlenebilirlik, 21 CFR Part 11 §11.10(e)). Değişiklik = yeni sürüm; onaylanınca ECN no verilir, eski sürüm kilitlenir.')}</p>
        : <p className="uep-not">{c('Yeni sürüm = kopya + numara; eski sürüm silinmez, açık emirler kendi sürümünde kalır. Satıra tıklayınca o sürüm açılır.')}</p>}
      <table className="uep-dg">
        <thead><tr>
          {ecn ? <th>ECN</th> : <th className="or">{c('Sürüm')}</th>}
          <th>{c('Tarih')}</th>
          {ecn && <th className="or">{c('Sürüm')}</th>}
          <th>{c(ecn ? 'Ne değişti / gerekçe' : 'Not')}</th><th>{c('Hazırlayan')}</th>{ecn && <th>{c('Onaylayan ✍')}</th>}
          <th className="sg">{c('Maliyet')}</th><th className="or">{c('Açık emir')}</th><th className="or">{c('Bileşen / Opr.')}{ecn ? ` / ${c('Kontrol')}` : ''}</th><th>{c('Durum')}</th>
        </tr></thead>
        <tbody>
          {surumler.map(s => (
            <tr key={s.id} className={s.id === agacId ? 'secili' : ''} style={{ cursor: 'pointer' }} onClick={() => { if (s.id !== agacId) git(`/urun-agaci/${s.id}`) }}>
              {ecn ? <td>{s.ecnNo || <span className="sl">—</span>}</td> : <td className="or">v{s.surum}</td>}
              <td>{ecn ? (s.onayTarihi ? tarihSaat(s.onayTarihi) : s.onayaGonderme ? `${tarihSaat(s.onayaGonderme)} (${c('onayda')})` : s.degisme ? tarihSaat(s.degisme) : '') : (s.degisme ? tarih(s.degisme) : '')}</td>
              {ecn && <td className="or">v{s.surum}</td>}
              <td>{s.onayGerekce || s.notlar || <span className="sl">—</span>}</td>
              <td>{s.hazirlayan || s.degistiren}</td>{ecn && <td>{s.onaylayan || <span className="sl">—</span>}</td>}
              <td className="sg">{para.format(s.maliyet)}</td><td className="or">{s.acikEmir}</td>
              <td className="or">{s.bilesen} / {s.operasyon}{ecn ? ` / ${s.kontrol}` : ''}</td><td>{rozet(s)}</td>
            </tr>))}
        </tbody>
      </table>
    </div>
  );
}
