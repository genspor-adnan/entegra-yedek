import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni, type Kosul } from '../../api/sozlesme';
import { GenForm } from '../../bilesenler/GenForm';
import { mesaj } from '../../bilesenler/mesaj';
import { TarafArama } from '../../bilesenler/TarafArama';

/**
 * PLANLI GİDER KARTININ SEÇİCİLERİ.
 *
 * ÖDENECEK YER (TEDARİKÇİ) - kullanıcı kararı 25.10.2026: serbest yazılmaz, YALNIZ tedarikçi listesinden
 * seçilir (elektrik kurumu, su idaresi, kira ödenen yer). Arama ortak cari araması (TarafArama), tedarikçi
 * rolüyle sınırlı (`tedarikci = 1`, Tedarikçi Listesi'nin süzgeciyle aynı). Aramanın kendi "＋ Yeni"si
 * KAPALI: o pencere cariyi müşteri varsayılanıyla açardı. Yerine "＋ Yeni tedarikçi" Tedarikçi
 * Listesi'nin varsayılanlarıyla (tedarikçi işaretli) kart açar; kaydedince seçili gelir.
 */
const TEDARIKCI: Kosul = { alan: 'tedarikci', op: 'esit', deger: 1 };

export function TedarikciSecici({ deger, tarafId, kilitli, hata, onSec, onKartAc }: {
  deger: string; tarafId: number | null; kilitli: boolean; hata?: string;
  onSec(s: { id: number; unvan: string } | null): void;
  onKartAc(id: number): void;
}) {
  const [acik, setAcik] = useState(false);
  const [yeni, setYeni] = useState(false);
  const yeniSecildi = (id: number) => {
    setYeni(false);
    api.liste('cari', { sayfa: 1, boyut: 1, filtre: { alan: 'id', op: 'esit', deger: id } })
      .then(y => onSec({ id, unvan: String(y.satirlar[0]?.unvan ?? '') }))
      .catch(h => mesaj(hataMetni(h)));
  };
  return (
    <>
      <div className="pg-yanyana">
        <span className="lookup-kutu">
          <input readOnly value={deger} placeholder="Tedarikçi seçin…" disabled={kilitli}
                 onMouseDown={e => { if (!kilitli) { e.preventDefault(); setAcik(true) } }}
                 onKeyDown={e => { if (!kilitli && (e.key === 'Enter' || e.key === 'F4')) { e.preventDefault(); setAcik(true) } }} />
          {!kilitli && deger && <button type="button" className="mini" title="Boşalt" onClick={() => onSec(null)}>×</button>}
          {!kilitli && <button type="button" className="mini" title="Tedarikçi ara (F4)" onClick={() => setAcik(true)}>…</button>}
        </span>
        {tarafId ? <button type="button" className="pg-bag" title="Tedarikçi kartını yeni sekmede aç" onClick={() => onKartAc(tarafId)}>Kart ›</button> : null}
        {!kilitli && <button type="button" className="pg-bag" title="Listede yoksa yeni tedarikçi kartı" onClick={() => setYeni(true)}>＋ Yeni tedarikçi</button>}
      </div>
      {hata && <span className="pg-hata">{hata}</span>}
      <TarafArama acik={acik} kaynaklar={['cari']} ekFiltre={TEDARIKCI} kartYok
                  yerTutucu="Tedarikçi ara (ünvan, kod, vergi no, telefon)…"
                  onKapat={() => setAcik(false)}
                  onSec={s => { setAcik(false); onSec({ id: s.id, unvan: s.unvan }) }} />
      {yeni && (
        <GenForm kaynak="cari" id="yeni" baslik="Yeni Tedarikçi" cariyeBaglaGizli
                 yeniKayitVarsayilanlari={{ musteri: false, tedarikci: true }}
                 onKapat={() => setYeni(false)}
                 onKaydedildi={id => yeniSecildi(id)} />
      )}
    </>
  );
}

/**
 * Kartta yalnız id'si gelen alanın görünen adı (masraf merkezi, sorumlu, ödeme hesabı): sunucu adı
 * vermediyse ilgili listeden tek satır okunur. Okunamazsa (yetki yok) "#id" yazılır.
 */
export function useKayitAdi(kaynak: string, id: number | null | undefined, verilen?: string, alanlar: string[] = ['ad']) {
  const [ad, setAd] = useState('');
  const anahtar = alanlar.join(',');
  useEffect(() => {
    if (!id || verilen) { setAd(''); return }
    let iptal = false;
    api.liste(kaynak, { sayfa: 1, boyut: 1, filtre: { alan: 'id', op: 'esit', deger: id } })
      .then(y => {
        const s = y.satirlar[0];
        const bulunan = s ? anahtar.split(',').map(a => s[a]).find(v => v != null && v !== '') : null;
        if (!iptal) setAd(bulunan != null ? String(bulunan) : `#${id}`);
      })
      .catch(() => { if (!iptal) setAd(`#${id}`) });
    return () => { iptal = true };
  }, [kaynak, id, verilen, anahtar]);
  return verilen || (id ? ad : '');
}
