import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import type { KartRolBilgisi } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';

/**
 * Personel/kişi kartında KULLANICI ROLLERİ (kullanıcı: "personel kartında rolü
 * görebilmem ve istersem değiştirebilmem lazım" + "çok rollülük ekle").
 *
 * Rol `taraf_kullanici` kaydında durur, kartın kendi alanı değildir - bu yüzden
 * kart kaydetmeye bağlı değil: seçim ANINDA uygulanır (rol atama ayrı bir
 * yetkidir ve islem_log'a yazılır). Kartın kullanıcı hesabı yoksa bölüm bilgi
 * satırı olarak kalır.
 *
 * ÇOK ROL (665): kişinin bir ANA rolü (asıl işi - "Doktor") ve istediği kadar
 * EK rolü ("İskonto Onaylayanlar") olur; yetki ikisinin birleşimidir. Ana rol
 * combo, ek roller işaret kutusu: ana rolün tek olması bir kural, ek rollerin
 * çokluğu ise beklenen durum - ikisini aynı kutuya koymak "hangisi asıl işi"
 * sorusunu cevapsız bırakırdı.
 */
/**
 * AYNI KARTIN IKI YERDE CIZILMESI (794): rol hem kimlik seridinde (`sade`) hem
 * İş Bilgileri kutusunda (`isBilgi`) duruyor. Birinde yapilan degisiklik
 * otekinde ESKI degeri birakirsa kullanici hangisinin dogru oldugunu bilemez -
 * degisiklik sonrasi ayni karta bakan butun ornekler tazelenir.
 */
const dinleyiciler = new Set<(kartId: number) => void>();

/** Personelde ana rolun neden kapali oldugunu soyleyen tek metin. */
const KADRO_IPUCU = "Ana rol Kadro Geçmişi'nden, yürürlük tarihiyle değişir";

/**
 * KADRO AGACI SECENEKLERI (847, kullanici: "kartta ana rol ve kadro
 * geçmişindeki ana rol comboları ağaç şeklinde olsun"). Hiyerarsi
 * `rol.ust_rol_id`de; combo girintiyi derinlikten uretir. Ustu listede
 * OLMAYAN rol (pasif ust, portal rolu) kok sayilir - yoksa dal asili kalir
 * ve rol comboda hic gorunmezdi.
 */
function rolAgaci(roller: { id: number; ad: string; ustId?: number | null }[]) {
  const varlar = new Set(roller.map(r => r.id));
  const cocuk = new Map<number, typeof roller>();
  const kokler: typeof roller = [];
  roller.forEach(r => {
    const ust = r.ustId && varlar.has(r.ustId) ? r.ustId : null;
    if (ust) cocuk.set(ust, [...(cocuk.get(ust) ?? []), r]);
    else kokler.push(r);
  });
  const sirala = (l: typeof roller) => l.sort((a, b) => a.ad.localeCompare(b.ad, 'tr'));
  sirala(kokler); cocuk.forEach(sirala);

  const sonuc: { id: number; etiket: string }[] = [];
  const gez = (r: typeof roller[number], derinlik: number) => {
    sonuc.push({
      id: r.id,
      etiket: `${'  '.repeat(derinlik)}${derinlik > 0 ? '└ ' : ''}${r.ad}`,
    });
    (cocuk.get(r.id) ?? []).forEach(c => gez(c, derinlik + 1));
  };
  kokler.forEach(r => gez(r, 0));
  return sonuc;
}
const rolDegisti = (kartId: number) => dinleyiciler.forEach(d => d(kartId));

export function KartKullaniciRolu({ kartId, saltOkunur, sade, isBilgi, yeniKayit }: {
  kartId: number;
  saltOkunur: boolean;
  /**
   * YENI PERSONEL (845, kullanici: "yeni pers kart actim ana rol yoktu
   * ekleyemedim.. zorunlu alan olmali"): kayit henuz yok, hesap da yok -
   * secim KARTIN state'inde tutulur ve Kaydet'ten SONRA uygulanir. Bu modda
   * bilesen sunucuya yazmaz, yalniz rol listesini gosterir (`kartId` 0).
   */
  yeniKayit?: { secili: number; onSec(rolId: number): void };
  /** Kimlik seridinde tek alan olarak cizilir (kutu/baslik yok). */
  sade?: boolean;
  /**
   * IS BILGILERI KUTUSUNUN ICINDE (794, kullanici: "personelde İş Bilgileri
   * bölümünde alta Ana Rol (zorunlu) ve Yan Rol combo ekle"): kendi kutusu
   * ("Kullanıcı Rolleri") yerine iki combo olarak cizilir - rol, personelin
   * IS bilgisidir; ayri bir kutuda dururken kartin en altinda kaliyordu.
   * Yan rol combodan SECILINCE eklenir, secilenler rozet olarak altta durur.
   */
  isBilgi?: boolean;
}) {
  const [bilgi, setBilgi] = useState<KartRolBilgisi | null>(null);
  const [hata, setHata] = useState('');
  const [islemde, setIslemde] = useState(false);
  const [mesaj, setMesaj] = useState('');

  const [surum, setSurum] = useState(0);
  useEffect(() => {
    let iptal = false;
    api.kartRol(kartId)
      .then(b => { if (!iptal) setBilgi(b) })
      .catch(h => { if (!iptal) setHata(hataMetni(h)) });
    return () => { iptal = true };
  }, [kartId, surum]);

  // Baska bir ornek ayni karti degistirdiyse bu ornek de tazelensin.
  useEffect(() => {
    const dinle = (k: number) => { if (k === kartId) setSurum(v => v + 1) };
    dinleyiciler.add(dinle);
    return () => { dinleyiciler.delete(dinle) };
  }, [kartId]);

  const degistir = async (rolId: number) => {
    setIslemde(true); setHata(''); setMesaj('');
    try {
      const y = await api.kartRolDegistir(kartId, rolId);
      setBilgi(y);
      rolDegisti(kartId);
      // Eski ana rol EK role duser (665) - kullanici bunu tahmin etmesin.
      setMesaj(`Ana rol "${y.rolAdi}" oldu; önceki rol ek rollere taşındı.`);
    } catch (h) { setHata(hataMetni(h)) } finally { setIslemde(false) }
  };

  const ekDegistir = async (rolId: number, secili: boolean) => {
    if (!bilgi) return;
    const yeni = secili
      ? [...bilgi.ekRolIdleri, rolId]
      : bilgi.ekRolIdleri.filter(r => r !== rolId);
    setIslemde(true); setHata(''); setMesaj('');
    try {
      const y = await api.kartEkRoller(kartId, yeni);
      setBilgi(y);
      rolDegisti(kartId);
      const ad = y.roller.find(r => r.id === rolId)?.ad ?? '';
      setMesaj(secili ? `"${ad}" ek rolü verildi.` : `"${ad}" ek rolü kaldırıldı.`);
    } catch (h) { setHata(hataMetni(h)) } finally { setIslemde(false) }
  };

  // Yetkisi olmayan kullanici rol bolumunu hic gormesin (GET 403 -> sessiz).
  if (hata && !bilgi) return null;

  // ANA ROL PERSONELDE KILITLI (843, kullanici: "kart tarafini da kilitle"):
  //   rol kadro defterinin bir parcasi - karttan tarihsiz degistirmek terfi
  //   gecmisini bozardi. Sunucu da ayni istegi reddediyor.
  const rolKilitli = Boolean(bilgi?.personel);
  const anaCombo = !bilgi?.kullaniciVar ? null : (
    <select value={bilgi.rolId} disabled={saltOkunur || islemde || rolKilitli}
            title={rolKilitli ? KADRO_IPUCU : undefined}
            onChange={e => void degistir(Number(e.target.value))}>
      {rolAgaci(bilgi.roller).map(r =>
        <option key={r.id} value={r.id}>{r.etiket}</option>)}
    </select>
  );

  // YENI KAYIT: hesap yok, secim kartta bekler (845).
  if (yeniKayit) {
    return (
      <label className="alan tip-kod">
        <span className="etiket zorunlu-isaret">Ana Rol</span>
        <select value={yeniKayit.secili || ''} disabled={saltOkunur}
                onChange={e => yeniKayit.onSec(Number(e.target.value))}>
          <option value="">— seçiniz —</option>
          {rolAgaci(bilgi?.roller ?? []).map(r =>
            <option key={r.id} value={r.id}>{r.etiket}</option>)}
        </select>
      </label>
    );
  }

  // IS BILGILERI modu: iki combo yan yana (kutu/baslik yok - kutunun icindeyiz).
  if (isBilgi) {
    if (!bilgi) return null;
    if (!bilgi.kullaniciVar) {
      return <div className="not">Bu personelin kullanıcı hesabı yok - rol
        ataması Yönetim › Kullanıcılar'dan hesap açılınca yapılır.</div>;
    }
    // YAN ROL COMBOSU KALKTI (844, kullanici: "yan rol comboyu kaldır"):
    //   Is Bilgileri kutusunda tek soru "bu kisinin rolu ne". Yan roller
    //   Yonetim > Kullanicilar kartindaki "Ek roller" listesinden verilir -
    //   mevcut yan roller burada yalnizca ROZET olarak okunur.
    const ekler = bilgi.roller.filter(r => bilgi.ekRolIdleri.includes(r.id));
    return (
      <>
        <label className="alan tip-kod">
          {/* ZORUNLU: kullanici hesabinin rolsuz kalmasi mumkun degil -
              "Rol Atanmamış" da bir roldur ve listede gelir (786'dan beri
              kilitli sistem rolu). */}
          <span className="etiket zorunlu-isaret">Ana Rol</span>
          {anaCombo}
        </label>
        {ekler.length > 0 && (
          <label className="alan tip-kod">
            <span className="etiket">Yan Roller</span>
            <span className="secim-rozetleri">
              {ekler.map(r => <span key={r.id} className="rozet mavi">{r.ad}</span>)}
            </span>
          </label>
        )}
        {hata && <div className="alan-hata">{hata}</div>}
        {mesaj && <div className="bilgi-kutusu">{mesaj}</div>}
      </>
    );
  }

  // SERIT modu: kimlik seridinde departmanin sagindaki tek alan. Ek roller
  //   burada DUZENLENMEZ, yalniz sayisi yazar - serit dar, karar yeri kart.
  if (sade) {
    if (!anaCombo || !bilgi) return null;
    return (
      <label className="alan tip-kod">
        <span className="etiket zorunlu-isaret">Ana Rol</span>
        {anaCombo}
        {bilgi.ekRolIdleri.length > 0 && (
          <span className="rozet" title={ekRolAdlari(bilgi)}>
            +{bilgi.ekRolIdleri.length} ek rol
          </span>
        )}
      </label>
    );
  }

  return (
    <div className="kagrup">
      <h6>Kullanıcı Rolleri</h6>
      <div className="alan-izgara tek-sutun">
        {!bilgi ? <div className="yukleniyor">Yükleniyor…</div>
         : !bilgi.kullaniciVar ? (
           <div className="not">Bu kartın kullanıcı hesabı yok.</div>
         ) : (
           <>
             <label className="alan tip-kod">
               <span className="etiket">Ana rol</span>
               {anaCombo}
             </label>

             <div className="alan">
               <span className="etiket">Ek roller</span>
               <div className="secim-listesi">
                 {bilgi.roller.filter(r => r.id !== bilgi.rolId).map(r => (
                   <label key={r.id} className="secim-satiri">
                     <input type="checkbox"
                            checked={bilgi.ekRolIdleri.includes(r.id)}
                            disabled={saltOkunur || islemde}
                            onChange={e => void ekDegistir(r.id, e.target.checked)} />
                     <span>{r.ad}</span>
                   </label>
                 ))}
               </div>
             </div>

             {/* NOT `.alan`IN DISINDA: `.alan` etiket|deger izgarasidir, notu
                 icine koyunca deger kolonuna sikisip kelime kelime kiriliyordu
                 (kullanici). Izgaranin kendi satiri olarak TAM GENISLIK alir ve
                 soldan saga tek satir okunur. */}
             <div className="not not-tamsatir">
               Yetki, ana rol ile ek rollerin <b>birleşimidir</b>; sayısal
               sınırlarda (ör. iskonto tavanı) en yüksek değer geçerli olur.
             </div>
           </>
         )}
        {hata && <div className="alan-hata">{hata}</div>}
        {mesaj && <div className="bilgi-kutusu">{mesaj}</div>}
      </div>
    </div>
  );
}

function ekRolAdlari(b: KartRolBilgisi) {
  return b.roller.filter(r => b.ekRolIdleri.includes(r.id)).map(r => r.ad).join(', ');
}
