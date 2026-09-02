import { useCallback, useEffect, useMemo, useState } from 'react';
import { GenForm } from '../bilesenler/GenForm';
import { api } from '../api/istemci';
import { guvenli, onay } from '../bilesenler/mesaj';

/**
 * KATEGORİLER (345/346, kullanıcı: "kategorileri 2 gride böl - solda stok,
 * sağda hizmet; tür ortak yok; listeyi AĞAÇ yap, alt kategoriler tıklanınca
 * açılsın, varsayılan kapalı; kod sırası").
 *
 * Düz grid yerine ağaç: kategori sınırsız derinlikte (270) ve asıl soru
 * "hangi kategorinin altında" - girintili düz liste bunu ancak sıralama
 * doğruysa gösteriyordu. Ağaç kapalı açılır: on binlik ağaçta bile ekran
 * köklerle başlar.
 *
 * Araç şeridi entegrasyon ekranındaki desen: arama/Grup/Analiz/Aksiyon
 * kombosu yok, Yeni-Düzenle-Sil sağa yanaşık.
 */
type Taraf = 1 | 2;

type Kategori = {
  id: number; kod: string; ad: string; ustId: number | null;
  aktif: number; stokSayisi: number; hizmetSayisi: number;
};

export function Kategoriler() {
  const [kayitlar, setKayitlar] = useState<Kategori[]>([]);
  const [secili, setSecili] = useState<Record<Taraf, number | null>>({ 1: null, 2: null });
  const [acik, setAcik] = useState<Set<number>>(new Set());
  const [kart, setKart] = useState<{ taraf: Taraf; id: number | 'yeni' } | null>(null);

  const yukle = useCallback(async () => {
    // Kategori sayısı küçük (yüzler): tek istekte gelir, ağaç istemcide
    //   kurulur - her dal açılışında sunucuya gitmek gereksiz gecikme.
    const y = await api.liste('kategori', { sayfa: 1, boyut: 1000 });
    setKayitlar((y.satirlar ?? []).map(s => ({
      id: Number(s.id), kod: String(s.kod ?? ''), ad: String(s.ad ?? ''),
      ustId: s.ustId === null || s.ustId === undefined ? null : Number(s.ustId),
      aktif: Number(s.aktif ?? 1),
      stokSayisi: Number(s.stokSayisi ?? 0), hizmetSayisi: Number(s.hizmetSayisi ?? 0),
      tur: Number(s.tur ?? 1),
    })) as unknown as Kategori[]);
  }, []);

  useEffect(() => { void guvenli(yukle) }, [yukle]);

  /** Türün kayıtları, KOD sırasına göre (kullanıcı) ve üst -> alt haritası. */
  const dallar = useMemo(() => {
    const harita = new Map<number, Kategori[]>();
    const tumu = kayitlar.slice().sort((a, b) =>
      a.kod.localeCompare(b.kod, 'tr') || a.ad.localeCompare(b.ad, 'tr'));
    tumu.forEach(k => {
      const ust = k.ustId ?? 0;
      harita.set(ust, [...(harita.get(ust) ?? []), k]);
    });
    return harita;
  }, [kayitlar]);

  const turSuz = (taraf: Taraf, liste: Kategori[]) =>
    liste.filter(k => Number((k as unknown as { tur: number }).tur) === taraf);

  const sil = async (satir: Kategori | undefined) => {
    if (!satir) return;
    if (!await onay(`"${satir.ad}" kategorisi silinsin mi?`)) return;
    await guvenli(async () => {
      await api.kartSil('kategori', satir.id);
      await yukle();
    });
  };

  const seciliKayit = (taraf: Taraf) => kayitlar.find(k => k.id === secili[taraf]);

  const ac = (id: number) => setAcik(s => {
    const y = new Set(s);
    y.has(id) ? y.delete(id) : y.add(id);
    return y;
  });

  /** Bir dalı ve (açıksa) altını çizer. */
  /**
   * Bir dalı ve (açıksa) altını çizer.
   *
   * DÜZEN (kullanıcı): KOD satırın sol başında ve SABİT genişlikte; ağaç
   * girintisi yalnız ok+ad bloğuna uygulanır. Girinti satırın kendisine
   * verilince kod sütunu da kayıyor ve her seviyede farklı yerden
   * başlıyordu - kodlar artık her satırda aynı hizada.
   */
  const dalCiz = (taraf: Taraf, k: Kategori, derinlik: number): React.ReactNode => {
    const altlar = dallar.get(k.id) ?? [];
    const acikMi = acik.has(k.id);
    const okStil: React.CSSProperties = {
      flex: '0 0 16px', width: 16, height: 16, overflow: 'hidden',
      display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
      // Ok KARAKTERI buyuk (kullanici): 10px'te tiklanacak yer de zor
      //   bulunuyordu; kutu 16px, karakter 14px ve koyu.
      fontSize: 14, lineHeight: 1, color: 'var(--yazi2)', cursor: 'pointer',
    };
    return (
      <div key={k.id}>
        <div className={`kat-satir${secili[taraf] === k.id ? ' on' : ''}`}
             style={{ height: 20, lineHeight: '18px', whiteSpace: 'nowrap', paddingLeft: 6 }}
             onClick={() => setSecili(s => ({ ...s, [taraf]: k.id }))}
             onDoubleClick={() => setKart({ taraf, id: k.id })}>
          {/* KOD - sol baş, sabit sütun. */}
          <span className="kod"
                style={{ flex: '0 0 78px', width: 78, overflow: 'hidden',
                         textOverflow: 'ellipsis', whiteSpace: 'nowrap', fontSize: 10.5 }}>
            {k.kod}
          </span>

          {/* AĞAÇ: girinti burada - kodu etkilemez. */}
          <div style={{ display: 'flex', alignItems: 'center', gap: 8,
                        flex: 1, minWidth: 0, paddingLeft: derinlik * 22 }}>
            {altlar.length > 0 ? (
              <span style={okStil} onClick={e => { e.stopPropagation(); ac(k.id) }}>
                {acikMi ? '▾' : '▸'}
              </span>
            ) : <span style={{ ...okStil, visibility: 'hidden' }} />}
            <span className="ad"
                  style={{ flex: 1, minWidth: 0, overflow: 'hidden',
                           textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
              {k.ad}
            </span>
          </div>

          <span className="sonuk sayi"
                style={{ flex: 'none', marginLeft: 10, minWidth: 34, textAlign: 'right' }}>
            {taraf === 1 ? k.stokSayisi : k.hizmetSayisi}
          </span>
          {k.aktif !== 1 && <span className="rozet gri">Pasif</span>}
        </div>
        {acikMi && altlar.map(a => dalCiz(taraf, a, derinlik + 1))}
      </div>
    );
  };

  const bolme = (taraf: Taraf, baslik: string) => {
    const kokler = turSuz(taraf, dallar.get(0) ?? []);
    const sec = seciliKayit(taraf);
    return (
      <div className="kagrup" style={{ flex: '1 1 0', minWidth: 0 }}>
        <h6>{baslik}</h6>
        <div className="cipler">
          <span className="sonuk">{kokler.length} kök kategori</span>
          <div className="arac-cubugu">
            <button className="d bir" onClick={() => setKart({ taraf, id: 'yeni' })}>
              ＋ Yeni
            </button>
            <button className="d" disabled={!sec}
                    onClick={() => sec && setKart({ taraf, id: sec.id })}>✎ Düzenle</button>
            <button className="d" disabled={!sec} onClick={() => void sil(sec)}>🗑 Sil</button>
            <button className="d" onClick={() => setAcik(new Set())}>⇱ Tümünü Kapat</button>
          </div>
        </div>
        <div className="kat-agac">
          {kokler.length === 0 && <div className="not">Kategori yok.</div>}
          {kokler.map(k => dalCiz(taraf, k, 0))}
        </div>
      </div>
    );
  };

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Kategoriler</h1>
          <span className="yol">Yönetim › Kategoriler</span>
        </div>
      </div>

      <div style={{ display: 'flex', gap: 16, alignItems: 'flex-start' }}>
        {bolme(1, 'Stok Kategorileri')}
        {bolme(2, 'Hizmet Kategorileri')}
      </div>

      <div className="not">
        Ağaç <b>kapalı</b> açılır: ▸ ile alt kategoriler görünür. Satıra çift
        tıklamak kartı açar. Kategori <b>tek listeye</b> aittir - türü kartta
        değiştirilir. Sağdaki sayı, o kategoriyi kullanan
        {' '}stok / hizmet sayısıdır.
      </div>

      {kart && (
        <GenForm
          kaynak="kategori"
          id={kart.id}
          baslik="Kategori"
          // Yeni kayit ACILDIGI BOLMENIN turuyle gelir; secili dal varsa onun
          //   ALTINA acilir - kullanici kartta ust kategoriyi elle aramasin.
          yeniKayitVarsayilanlari={{
            tur: kart.taraf,
            ...(kart.id === 'yeni' && secili[kart.taraf]
              ? { ustId: secili[kart.taraf] as number } : {}),
          }}
          onKapat={() => setKart(null)}
          onKaydedildi={() => { setKart(null); void guvenli(yukle) }}
        />
      )}
    </>
  );
}
