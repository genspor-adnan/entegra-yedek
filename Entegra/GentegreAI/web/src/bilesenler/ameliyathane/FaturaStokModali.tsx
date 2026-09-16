import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { FaturaDurumu } from '../../api/uclar/ameliyathane';
import { hataMetni } from '../../api/sozlesme';
import { Modal } from '../Modal';
import { paraYaz } from '../bicim';

/**
 * AMELİYAT → FATURA ve SARF → STOK (720).
 *
 * TEK EKRAN, İKİ İŞ - ama AYNI DÜĞME DEĞİL. İkisi farklı defterlere yazıyor
 * (ücret hasta başvurusuna, malzeme stok çıkış fişine) ve farklı yetki
 * istiyor; tek "aktar" düğmesi yapsaydık, faturayı onaylayan kişi farkında
 * olmadan depo sayımını da değiştirmiş olurdu.
 *
 * FATURAYA YANSIYAN MALZEME DE STOKTAN DÜŞER. Ekran bunu açıkça yazıyor,
 * çünkü ilk bakışta çift sayım gibi görünüyor: değil - başvuru (tür 19) stoğa
 * dokunmaz, çıkış fişi hastaya yansımaz.
 *
 * ZATEN AKTARILMIŞ SATIR SOLUK GÖSTERİLİR, gizlenmez: "neden bu kalem
 * eklenmedi" sorusunun yanıtı listede durmalı.
 */
const UTS_AD: Record<number, string> = {
  0: '', 1: 'ÜTS bekliyor', 2: 'ÜTS bildirildi', 3: 'ÜTS hata',
};

export function FaturaStokModali({ ameliyatId, ameliyatNo, onKapat, onTamam }: {
  ameliyatId: number;
  ameliyatNo?: string;
  onKapat(): void;
  onTamam?(): void;
}) {
  const [veri, setVeri] = useState<FaturaDurumu | null>(null);
  const [malzemeDahil, setMalzemeDahil] = useState(true);
  const [calisiyor, setCalisiyor] = useState('');
  const [hata, setHata] = useState('');
  const [bilgi, setBilgi] = useState<string[]>([]);
  const [utsHata, setUtsHata] = useState<string[]>([]);

  const yukle = useCallback(async () => {
    try { setVeri(await api.ameliyatFatura(ameliyatId)); setHata('') }
    catch (h) { setHata(hataMetni(h)) }
  }, [ameliyatId]);
  useEffect(() => { void yukle() }, [yukle]);

  const faturala = async () => {
    setHata(''); setUtsHata([]); setCalisiyor('fatura');
    try {
      const y = await api.ameliyatFaturala(ameliyatId, { malzemeDahil });
      setBilgi([
        `${y.islemSatiri} işlem + ${y.malzemeSatiri} malzeme satırı aktarıldı.`
        + (y.yeniBasvuru ? ' Yeni hasta başvurusu açıldı.' : ''),
        ...y.uyarilar,
      ]);
      await yukle();
      onTamam?.();
    } catch (h) { setHata(hataMetni(h)) } finally { setCalisiyor('') }
  };

  const stokDus = async () => {
    setHata(''); setUtsHata([]); setCalisiyor('stok');
    try {
      const y = await api.ameliyatStokDus(ameliyatId, {});
      setBilgi([
        `${y.dusulen} kalem stoktan düşüldü (fiş #${y.fisId}).`,
        // İZLEMSİZ satır sessiz geçmez: lot/seri eşleşmeyen malzeme için
        //   "hangi lot gitti" sorusu sonradan yanıtlanamaz.
        ...(y.izlemsiz ? [`${y.izlemsiz} kalem lot/seri bağı olmadan düşüldü.`] : []),
        // ÜTS SATIR SATIR: biri reddedilse de düşüm geçerlidir ve öteki
        //   satırlar bildirilmiştir - tek "başarısız" mesajı bunu gizlerdi.
        ...utsYaz(y.uts, y.utsMesaj),
        ...(y.utsBekleyen ? [`${y.utsBekleyen} implant ÜTS bildirimi bekliyor.`] : []),
        ...y.uyarilar,
        ...y.kritik.map(k => `Kritik stok: ${k.ad} — kalan ${k.kalan} (min ${k.minStok})`),
      ]);
      await yukle();
      onTamam?.();
    } catch (h) { setHata(hataMetni(h)) } finally { setCalisiyor('') }
  };

  /** ÜTS sonucunu iki çağrı da aynı biçimde raporlar. */
  const utsYaz = (uts: { ad: string; lot: string | null; basarili: boolean; mesaj: string }[],
                  utsMesaj: string) => {
    setUtsHata([
      ...uts.filter(u => !u.basarili).map(u => `ÜTS reddetti — ${u.ad}: ${u.mesaj}`),
      ...(utsMesaj ? [`ÜTS bildirimi yapılamadı: ${utsMesaj}`] : []),
    ]);
    return uts.filter(u => u.basarili)
              .map(u => `ÜTS kullanım bildirildi: ${u.ad}${u.lot ? ` (lot ${u.lot})` : ''}`);
  };

  const utsTekrar = async () => {
    setHata(''); setUtsHata([]); setCalisiyor('uts');
    try {
      const y = await api.ameliyatUtsBildir(ameliyatId);
      const ok = utsYaz(y.uts, y.utsMesaj);
      setBilgi(ok.length ? ok : ['Bildirilen implant yok.']);
      await yukle();
      onTamam?.();
    } catch (h) { setHata(hataMetni(h)) } finally { setCalisiyor('') }
  };

  const o = veri?.ozet;
  const faturalanacak = (o?.faturasizIslem ?? 0) + (malzemeDahil ? o?.faturasizSarf ?? 0 : 0);

  return (
    <Modal baslik={`Fatura & Stok${ameliyatNo ? ` — ${ameliyatNo}` : ''}`} onKapat={onKapat}
           alt={
             <>
               <button className="d onay" disabled={!!calisiyor || faturalanacak === 0}
                       onClick={() => void faturala()}>
                 {calisiyor === 'fatura' ? '⏳ Aktarılıyor…'
                   : `🧾 Faturaya Aktar${faturalanacak ? ` (${faturalanacak})` : ''}`}
               </button>
               <button className="d" disabled={!!calisiyor || (o?.dusulmemisSarf ?? 0) === 0}
                       onClick={() => void stokDus()}>
                 {calisiyor === 'stok' ? '⏳ Düşülüyor…'
                   : `📦 Stoktan Düş${o?.dusulmemisSarf ? ` (${o.dusulmemisSarf})` : ''}`}
               </button>
               {/* TEKRAR DENE yalnız bekleyen/hatalı implant varken: düşüm bir
                   daha çalışmaz, bildirimin kendi kapısı budur. */}
               {(o?.utsBekleyen ?? 0) > 0 && (
                 <button className="d" disabled={!!calisiyor}
                         onClick={() => void utsTekrar()}>
                   {calisiyor === 'uts' ? '⏳ Bildiriliyor…'
                     : `🏷 ÜTS Bildir (${o?.utsBekleyen})`}
                 </button>
               )}
               <button className="d" onClick={onKapat}>✖ Kapat</button>
             </>
           }>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {bilgi.length > 0 && (
        <div className="bilgi-kutusu">
          {bilgi.map((b, i) => <div key={i}>{b}</div>)}
        </div>
      )}
      {/* ÜTS REDDİ AYRI KUTUDA: yeşil bilgi kutusunun içinde kaybolmamalı -
          bildirilemeyen implant kurumun cevap vermesi gereken bir eksiktir. */}
      {utsHata.length > 0 && (
        <div className="uyari-kutusu">
          {utsHata.map((b, i) => <div key={i}>{b}</div>)}
        </div>
      )}

      <div className="kagrup">
        <h6>İşlemler → hasta başvurusu</h6>
        <div className="ds-dg"><table>
          <thead><tr>
            <th>İşlem</th><th style={{ width: 110 }}>SUT</th>
            <th style={{ width: 110 }} className="sag">Fiyat</th>
            <th style={{ width: 130 }} className="orta">Durum</th>
          </tr></thead>
          <tbody>
            {(veri?.islemler ?? []).map(i => (
              <tr key={i.id} className={i.belgeSatirId ? 'soluk' : ''}>
                <td>{i.ad}</td>
                <td>{i.sutKodu}</td>
                <td className="sag">{paraYaz(i.fiyat)}</td>
                <td className="orta">{i.belgeSatirId
                  ? <span className="rozet gri">aktarıldı</span>
                  : <span className="rozet mavi">bekliyor</span>}</td>
              </tr>
            ))}
            {veri && veri.islemler.length === 0 && (
              <tr><td colSpan={4} className="sonuk">İşlem satırı yok.</td></tr>)}
          </tbody>
        </table></div>
      </div>

      <div className="kagrup">
        <h6>Malzeme</h6>
        <div className="ds-dg"><table>
          <thead><tr>
            <th>Malzeme</th>
            <th style={{ width: 70 }} className="sag">Miktar</th>
            <th style={{ width: 110 }} className="sag">Fiyat</th>
            <th style={{ width: 120 }} className="orta">Ücret</th>
            <th style={{ width: 120 }} className="orta">Stok</th>
          </tr></thead>
          <tbody>
            {(veri?.sarflar ?? []).map(f => (
              <tr key={f.id}>
                <td>{f.ad}
                  {f.lot ? <span className="alan-notu"> · lot {f.lot}</span> : null}
                  {f.implant === 1 && <span className="rozet mor" style={{ marginLeft: 4 }}>implant</span>}
                  {f.utsDurum ? <span className="alan-notu"> · {UTS_AD[f.utsDurum]}</span> : null}
                </td>
                <td className="sag">{f.miktar}</td>
                <td className="sag">{f.faturaya === 1 ? paraYaz(f.fiyat ?? 0) : '—'}</td>
                <td className="orta">{f.faturaya !== 1
                  // PAKETE DAHİL malzeme hastaya YAZILMAZ ama stoktan düşer -
                  //   ikisinin ayrı kolon olmasının sebebi bu.
                  ? <span className="rozet gri">pakete dahil</span>
                  : f.belgeSatirId
                    ? <span className="rozet gri">aktarıldı</span>
                    : <span className="rozet mavi">bekliyor</span>}</td>
                <td className="orta">{!f.stokId
                  ? <span className="rozet uyari">stok kartı yok</span>
                  : f.cikisBelgeId
                    ? <span className="rozet ok">düşüldü</span>
                    : <span className="rozet mavi">bekliyor</span>}</td>
              </tr>
            ))}
            {veri && veri.sarflar.length === 0 && (
              <tr><td colSpan={5} className="sonuk">Malzeme satırı yok.</td></tr>)}
          </tbody>
        </table></div>
        <div className="alan-izgara tek-sutun">
          <label className="alan">
            <span className="etiket">Faturaya</span>
            <label className="secim-satiri">
              <input type="checkbox" checked={malzemeDahil}
                     onChange={e => setMalzemeDahil(e.target.checked)} />
              <span>Malzeme ücret satırları da aktarılsın</span>
            </label>
          </label>
        </div>
      </div>

      <div className="not">
        <b>İki ayrı defter.</b> Ücret <b>hasta başvurusuna</b> (tür 19) yazılır; başvuru
        stoğa dokunmaz, gerçek muhasebe hareketi faturaya dönüşünce oluşur. Malzeme
        ise <b>stok çıkış fişiyle</b> (tür 4) düşer. Faturaya yansıyan malzeme de
        düşer — çift sayım değil: iki kayıt iki ayrı deftere gidiyor.
        {o?.stoksuzSarf ? <> Stok kartı olmayan {o.stoksuzSarf} kalem düşülemez;
          önce stok kartı açılmalı.</> : null}
      </div>
    </Modal>
  );
}
