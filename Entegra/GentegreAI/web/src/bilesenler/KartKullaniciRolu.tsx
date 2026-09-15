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
export function KartKullaniciRolu({ kartId, saltOkunur, sade }: {
  kartId: number;
  saltOkunur: boolean;
  /** Kimlik seridinde tek alan olarak cizilir (kutu/baslik yok). */
  sade?: boolean;
}) {
  const [bilgi, setBilgi] = useState<KartRolBilgisi | null>(null);
  const [hata, setHata] = useState('');
  const [islemde, setIslemde] = useState(false);
  const [mesaj, setMesaj] = useState('');

  useEffect(() => {
    let iptal = false;
    api.kartRol(kartId)
      .then(b => { if (!iptal) setBilgi(b) })
      .catch(h => { if (!iptal) setHata(hataMetni(h)) });
    return () => { iptal = true };
  }, [kartId]);

  const degistir = async (rolId: number) => {
    setIslemde(true); setHata(''); setMesaj('');
    try {
      const y = await api.kartRolDegistir(kartId, rolId);
      setBilgi(y);
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
      const ad = y.roller.find(r => r.id === rolId)?.ad ?? '';
      setMesaj(secili ? `"${ad}" ek rolü verildi.` : `"${ad}" ek rolü kaldırıldı.`);
    } catch (h) { setHata(hataMetni(h)) } finally { setIslemde(false) }
  };

  // Yetkisi olmayan kullanici rol bolumunu hic gormesin (GET 403 -> sessiz).
  if (hata && !bilgi) return null;

  const anaCombo = !bilgi?.kullaniciVar ? null : (
    <select value={bilgi.rolId} disabled={saltOkunur || islemde}
            onChange={e => void degistir(Number(e.target.value))}>
      {bilgi.roller.map(r => <option key={r.id} value={r.id}>{r.ad}</option>)}
    </select>
  );

  // SERIT modu: kimlik seridinde departmanin sagindaki tek alan. Ek roller
  //   burada DUZENLENMEZ, yalniz sayisi yazar - serit dar, karar yeri kart.
  if (sade) {
    if (!anaCombo || !bilgi) return null;
    return (
      <label className="alan tip-kod">
        <span className="etiket zorunlu-isaret">Rol</span>
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
