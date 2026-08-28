import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { ayarOnbellegiTemizle } from '../api/ayarlar';
import { type AyarSatiri, hataMetni } from '../api/sozlesme';
import { YardimIkonu } from './YardimIkonu';
import { KodListesiModali } from './KodListesiModali';

/**
 * Ayar ekranlarinin ortak kancasi: /api/ayar'i yukler, tek alan yazar, hata ve
 * "kaydedildi" bilgisini yonetir. Genel Ayarlar ve Stok Ayarlari ayni listeyi
 * kullanir (beyaz liste sunucuda) - her ekran kendi anahtarlarini cizer.
 */
export function useAyarlar() {
  const [ayarlar, setAyarlar] = useState<AyarSatiri[]>([]);
  const [yukleniyor, setYukleniyor] = useState(true);
  const [hata, setHata] = useState<string | null>(null);
  const [bilgi, setBilgi] = useState<string | null>(null);

  const yukle = useCallback(async () => {
    try {
      setAyarlar(await api.ayarlar());
      setHata(null);
    } catch (h) {
      setHata(hataMetni(h));
    } finally { setYukleniyor(false) }
  }, []);

  useEffect(() => { void yukle() }, [yukle]);

  const yaz = useCallback(async (anahtar: string, yeni: string) => {
    try {
      setAyarlar(await api.ayarYaz(anahtar, yeni));
      ayarOnbellegiTemizle();          // acilacak ekranlar yeni degeri okusun
      setHata(null);
      setBilgi('Ayar kaydedildi.');
      setTimeout(() => setBilgi(null), 2500);
    } catch (h) {
      // ONCE tazele, SONRA hatayi yaz: yukle() basarida setHata(null) yaptigi
      //   icin ters sirada mesaj aninda siliniyordu.
      await yukle();
      setHata(hataMetni(h));
    }
  }, [yukle]);

  return { ayarlar, yukleniyor, hata, bilgi, yaz };
}

export type AyarTipi = 'sayi' | 'metin' | 'mantik' | 'secenek' | 'parola' | 'uzunMetin';

/**
 * Tek ayar satiri — GENEL KURAL: etiket EDITIN USTUNDE, aciklama alt paragrafta
 * degil editin SAGINDAKI "?" ikonunda (metin public.help'te).
 *
 * Kayit ANINDA: sayi/metin alanlar blur ya da Enter'da, mantik/secenek
 * degistigi anda yazilir. Tek alanlik ayarlara "Kaydet" dugmesi koymak
 * kullaniciyi bekletmekten baska ise yaramiyordu.
 */
export function AyarAlani({ anahtar, etiket, tip = 'sayi', secenekler, listeKod,
                            ayarlar, onYaz, genis }: {
  anahtar: string;
  etiket: string;
  tip?: AyarTipi;
  /** tip='secenek' icin: [{ deger, ad }]. */
  secenekler?: { deger: string; ad: string }[];
  /** Secenekleri kod listesinden cek (219): ayar degeri = deger ADI (or. 'TL').
      Verilirse ETIKET tiklanabilir olur ve jenerik KodListesiModali'ni acar -
      kullanici combo icerigini oradan ekler/siler/degistirir. */
  listeKod?: string;
  ayarlar: AyarSatiri[];
  onYaz(anahtar: string, deger: string): void | Promise<void>;
  /** Metin alanini genis ciz (kisa kodlarda dar durur). */
  genis?: boolean;
}) {
  const kayit = ayarlar.find(a => a.anahtar === anahtar);
  const kayitliDeger = kayit?.deger ?? '';
  const [taslak, setTaslak] = useState<string | null>(null);
  const deger = taslak ?? kayitliDeger;

  // Kod listesi secenekleri (219). Modal kapaninca `surum` artar, liste tazelenir.
  const [listeSecenekleri, setListeSecenekleri] =
    useState<{ deger: string; ad: string }[]>([]);
  const [listeModal, setListeModal] = useState(false);
  const [listeSurum, setListeSurum] = useState(0);
  useEffect(() => {
    if (!listeKod) return;
    let iptal = false;
    void (async () => {
      try {
        const y = await api.kodListe(listeKod);
        if (!iptal)
          setListeSecenekleri(y.degerler.filter(d => d.aktif === 1)
            .map(d => ({ deger: d.ad, ad: d.ad })));
      } catch { /* liste yoksa combo bos kalir */ }
    })();
    return () => { iptal = true };
  }, [listeKod, listeSurum]);

  const yardim = (
    // hepGoster (kullanici): her ayarin solunda "?" varsayilan olarak durur -
    //   metinsizse balon "Açıklama yok." der.
    <YardimIkonu anahtar={`ayar.${anahtar}`}
                 baslik={kayit?.yardimBaslik}
                 metin={kayit?.yardim} hepGoster />
  );

  const bitir = (v: string) => {
    setTaslak(null);
    if (v.trim() !== kayitliDeger) void onYaz(anahtar, v.trim());
  };

  // ONAY KUTUSU AYRI DUZEN (kullanici): kutu SOLDA, etiketi saginda. Diger
  //   alanlarda etiket ustte durur ama onay kutusunda bu, kutuyu etiketten
  //   koparip hangi ayara ait oldugunu belirsizlestiriyordu.
  if (tip === 'mantik') {
    return (
      <label className="alan ayar-onay">
        {/* (?) EN SOLDA (kullanici): isaretler kutunun/editin SOLUNDA hizali
            durur - saga koyulunca uzun etiketlerde saga savruluyor ve alanlar
            arasinda dikey hizasi kayboluyordu. */}
        {yardim}
        <input type="checkbox" checked={deger === '1'}
               onChange={e => { setTaslak(null); void onYaz(anahtar, e.target.checked ? '1' : '0') }} />
        <span className="etiket">{etiket}</span>
      </label>
    );
  }

  const secimListesi = listeKod ? listeSecenekleri : (secenekler ?? []);
  const comboMu = tip === 'secenek' || !!listeKod;

  return (
    <label className="alan">
      {/* listeKod'lu comboda etiket TIKLANABILIR (kullanici): liste icerigi
          jenerik modaldan yonetilir. */}
      {listeKod ? (
        <span className="etiket" role="button" tabIndex={0}
              title="Liste içeriğini düzenle" style={{ cursor: 'pointer' }}
              onClick={e => { e.preventDefault(); setListeModal(true) }}>
          {etiket} ✎
        </span>
      ) : (
        <span className="etiket">{etiket}</span>
      )}
      <span className="ikili">
        {yardim}
        {comboMu ? (
          <select value={deger}
                  onChange={e => { setTaslak(null); void onYaz(anahtar, e.target.value) }}>
            {/* Kayitli deger listede yoksa (silinmis) yine gorunsun - combo
                sessizce ilk secenege atlamasin. */}
            {listeKod && deger && !secimListesi.some(s => s.deger === deger) && (
              <option value={deger}>{deger}</option>
            )}
            {secimListesi.map(s => <option key={s.deger} value={s.deger}>{s.ad}</option>)}
          </select>
        ) : tip === 'uzunMetin' ? (
          // Sabit notlar gibi COK SATIRLI ayarlar: tek satirlik kutuda metnin
          //   yalniz bir parcasi gorunuyordu.
          <textarea className="genis-deger" rows={3}
                    value={deger}
                    onChange={e => setTaslak(e.target.value)}
                    onBlur={e => bitir(e.target.value)} />
        ) : (
          <input className={tip === 'sayi' ? 'hiza-sag' : genis ? 'genis-deger' : ''}
                 // Entegrator sifresi ekranda ACIK yazmasin. Deger sunucuda DUZ
                 //   METIN saklanir - gizleme yalniz omuz ustu okumaya karsi.
                 type={tip === 'parola' ? 'password' : undefined}
                 autoComplete={tip === 'parola' ? 'new-password' : undefined}
                 value={deger}
                 inputMode={tip === 'sayi' ? 'numeric' : undefined}
                 onChange={e => setTaslak(e.target.value)}
                 onBlur={e => bitir(e.target.value)}
                 onKeyDown={e => { if (e.key === 'Enter') (e.target as HTMLInputElement).blur() }} />
        )}
      </span>

      {listeKod && listeModal && (
        <KodListesiModali kod={listeKod} baslik={etiket}
          onKapat={() => { setListeModal(false); setListeSurum(t => t + 1) }} />
      )}
    </label>
  );
}
