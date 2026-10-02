import { useMemo, useState } from 'react';
import { Modal } from './Modal';
import { GenGrid } from './GenGrid';
import { AlerjiKarti } from './hasta/AlerjiKarti';
import { KronikTaniKarti } from './hasta/KronikTaniKarti';
import { IlacKaydiKarti } from './hasta/IlacKaydiKarti';
import { GecmisOlayKarti } from './hasta/GecmisOlayKarti';
import type { ListeSatiri } from '../api/sozlesme';
import { api } from '../api/istemci';
import { guvenli, mesaj, onay } from './mesaj';
import { c } from '../dil/ceviri';

/**
 * HASTA KAYITLARI PENCERESİ (kullanıcı: "alerji/kronik ve aktif ilaçlara
 * tıklandığında ekleme/düzenleme yap").
 *
 * Muayene kartının bağlam şeridindeki kutudan açılır: hekim muayeneden
 * çıkmadan hastanın alerjisini, kronik tanısını ya da kullandığı ilacı
 * ekler/düzeltir. Liste GENEL (GenGrid), kartlar mockup'lı özel kartlar -
 * kural ve yetki sunucuda, ekran yalnız hastaya süzer ve yeni kayıtta
 * hastayı (ve alerjide kaydı açan muayeneyi) önceden doldurur.
 */
export interface HastaKayitBolumu {
  kaynak: 'hasta-alerji' | 'hasta-kronik' | 'hasta-ilac' | 'hasta-gecmis';
  baslik: string;
  /** Yeni kayıtta önceden dolan alanlar (hasta hep dolar). */
  ekVarsayilan?: Record<string, number | string | boolean>;
}

export function HastaKayitPenceresi({ baslik, hastaId, hastaAdi, muayeneId, bolumler, onKapat, onDegisti }: {
  baslik: string;
  hastaId: number;
  hastaAdi?: string;
  /** Pencerenin açıldığı muayene (alerji kartı "kaydı açan muayene" yazar). */
  muayeneId?: number;
  bolumler: HastaKayitBolumu[];
  onKapat(): void;
  /** Kayıt eklenip/değişince (şerit tazelensin). */
  onDegisti(): void;
}) {
  const [secili, setSecili] = useState<Record<string, ListeSatiri | null>>({});
  const [kart, setKart] = useState<{ kaynak: string; id: number | 'yeni';
                                    varsayilan?: Record<string, number | string | boolean> } | null>(null);
  const [tazele, setTazele] = useState(0);
  const kartKapandi = () => { setKart(null); setTazele(t => t + 1); onDegisti() };
  // SİL (kullanıcı: "gridlere silme butonları da ekle"): yanlış girilmiş kayıt
  //   için. Yetki ve log (silmeden ÖNCE tam satır) sunucuda; ekran onay ister.
  //   İyileşen kronik / bırakılan ilaç için silme değil kartta "pasif" doğru
  //   yoldur - onay metni bunu söyler.
  const sil = (b: HastaKayitBolumu, s: ListeSatiri) => guvenli(async () => {
    if (!await onay(c('Seçili kayıt silinecek. Yalnız yanlış girilmiş kayıt için kullanın; geçerliliği biten kayıt kartta pasif yapılır. Onaylıyor musunuz?'), true)) return;
    await api.kartSil(b.kaynak, Number(s.id));
    mesaj(c('Kayıt silindi.'));
    setSecili(m => ({ ...m, [b.kaynak]: null }));
    setTazele(t => t + 1);
    onDegisti();
  });
  // SABIT FILTRE NESNESI SABIT: her cizimde yeni nesne GenGrid'i yeniden yukletir.
  const filtre = useMemo(() => ({ alan: 'hastaId', op: 'esit' as const, deger: hastaId }), [hastaId]);

  return (
    <>
      <Modal baslik={baslik} buyutmeYok onKapat={onKapat}
             alt={<button type="button" className="d" onClick={onKapat}>{c('Kapat')}</button>}>
        {bolumler.map(b => {
          const s = secili[b.kaynak] ?? null;
          return (
            <div key={b.kaynak} className="kagrup hasta-kayit-grid">
              <div className="numaralama-bas bitisik">
                <span className="baslik-eylem">
                  <button type="button" className="d bir"
                          onClick={() => setKart({ kaynak: b.kaynak, id: 'yeni',
                            varsayilan: { hastaId, ...(b.ekVarsayilan ?? {}) } })}>
                    ＋ {c('Ekle')}
                  </button>
                  <button type="button" className="d ikon-dugme" disabled={!s}
                          aria-label={c('Düzenle')}
                          title={s ? c('Seçili kaydı düzenle') : c('Önce satır seçin')}
                          onClick={() => s && setKart({ kaynak: b.kaynak, id: Number(s.id) })}>✎</button>
                  <button type="button" className="d sil ikon-dugme" disabled={!s}
                          aria-label={c('Sil')}
                          title={s ? c('Seçili kaydı sil') : c('Önce satır seçin')}
                          onClick={() => s && void sil(b, s)}>🗑</button>
                </span>
                <h6>{b.baslik}</h6>
              </div>
              <GenGrid
                key={`${b.kaynak}-${hastaId}-${tazele}`}
                kaynak={b.kaynak}
                gomulu seritGizli aramaGizli
                boyut={25}
                sabitFiltre={filtre}
                onSecimDegisti={r => setSecili(m => ({ ...m, [b.kaynak]: r }))}
                onSatirAc={r => setKart({ kaynak: b.kaynak, id: Number(r.id) })}
              />
            </div>
          );
        })}
      </Modal>

      {/* OZEL KARTLAR (mockup Ekranlar/Muayene/alerji_karti, kronik_tani_karti,
          kullanilan_ilac_karti). */}
      {kart && kart.kaynak === 'hasta-alerji' && (
        <AlerjiKarti id={kart.id} hastaId={hastaId} hastaAdi={hastaAdi} muayeneId={muayeneId}
          onKapat={kartKapandi} />
      )}
      {kart && kart.kaynak === 'hasta-kronik' && (
        <KronikTaniKarti id={kart.id} hastaId={hastaId} hastaAdi={hastaAdi} muayeneId={muayeneId}
          onKapat={kartKapandi} />
      )}
      {kart && kart.kaynak === 'hasta-ilac' && (
        <IlacKaydiKarti id={kart.id} hastaId={hastaId} hastaAdi={hastaAdi} onKapat={kartKapandi} />
      )}
      {kart && kart.kaynak === 'hasta-gecmis' && (
        <GecmisOlayKarti id={kart.id} hastaId={hastaId} hastaAdi={hastaAdi} muayeneId={muayeneId}
          onKapat={kartKapandi} />
      )}
    </>
  );
}
