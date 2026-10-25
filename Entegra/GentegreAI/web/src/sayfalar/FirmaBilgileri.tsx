import { useCallback, useContext, useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { onay } from '../bilesenler/mesaj';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import type { ListeSatiri } from '../api/sozlesme';
import { GenForm } from '../bilesenler/GenForm';
import { SeriKurallari } from '../bilesenler/ebelge/SeriKurallari';
import { XsltSablonlari } from '../bilesenler/ebelge/XsltSablonlari';
import { TurAyarlari, type EBelgeTuru } from '../bilesenler/ebelge/TurAyarlari';
import { c } from '../dil/ceviri';
import { EkranSekmesiBaglami, LISTE_TAZELE_OLAYI, sekmeAdi } from '../bilesenler/sekmeBaglami';

// Depolar SAYFADA DEGIL, subenin KARTINDA (kullanici): depo subeye ait, hangi
//   subenin deposu oldugu ancak kartin icinde belli oluyor.
// SEKME CUBUGU KALKTI (kullanici): kurum profili kendi ekranina tasininca
//   (Yonetim > Kurum Profili) geriye tek sekme kaliyordu - tek sekmeli serit
//   tiklanacak bir sey varmis izlenimi veriyordu. Sayfa dogrudan sube
//   listesidir.

/**
 * Sube kartinin e-Belge sekmesindeki ALT sekmeler (kullanici). Genel = kartin
 * kendi alanlari; digerleri Ayarlar'dan tasinan bolumler.
 *
 * TUR SEKMELERI MUKELLEFIYETE BAGLI (172): `mukellefAlani` isaretli degilse
 * sekme hic cizilmez - mukellefi olmadigimiz turun servis adresini ve sabit
 * notunu doldurmak ise yaramiyor, ekrani kalabaliklastiriyordu.
 */
const EBELGE_ALT = [
  { anahtar: 'genel',     baslik: 'Genel' },
  { anahtar: 'seri',      baslik: 'Seri Bilgileri' },
  { anahtar: 'xslt',      baslik: 'XSLT' },
  { anahtar: 'efatura',   baslik: 'e-Fatura',        mukellefAlani: 'efaturaMukellef' },
  { anahtar: 'earsiv',    baslik: 'e-Arşiv Fatura',  mukellefAlani: 'earsivMukellef' },
  { anahtar: 'eirsaliye', baslik: 'e-İrsaliye',      mukellefAlani: 'eirsaliyeMukellef' },
  { anahtar: 'esmm',      baslik: 'e-SMM',           mukellefAlani: 'esmmMukellef' },
] as const;

/** Kart seridinde kalan alanlar: ünvan, kısa ad, durum. Kimligin geri kalani
    kartin "Kimlik" sekmesinde - serit karti TANIMLAR, doldurmaz. */
const SERIT_ALANLARI = ['unvan', 'ad', 'aktif'];

/** LISTE_TAZELE_OLAYI ayrıntısı: şube kartı kaydedilince liste tazelenir. */
const SUBE_KAYNAGI = 'sube';

/**
 * FIRMA / SUBELER (Yonetim › Firma / Şubeler) — mockup: Ekranlar/firma_bilgileri.html
 *
 * EKRAN = SUBE LISTESI, kart KENDİ SEKMESİNDE acilir (25.10.2026; once modaldi): firma bilgisi
 * sayfaya gomulu dururken hangi kaydin duzenlendigi belirsizdi ve tek subeli
 * kurulumda bile sekme degistirmek gerekiyordu. Simdi liste tek gorunum,
 * "+ Yeni Şube" ve satirdaki "Düzenle" ayni karti acar.
 *
 * FIRMA = VARSAYILAN SUBE. Ayri bir "firma" tablosu ACILMADI: e-Belgede gonderici
 * taraf zaten sube bazlidir (fatura hangi subeden kesildiyse onun unvani ve adresi
 * gider), dolayisiyla firma bilgisi subenin kendisidir.
 *
 * e-BELGE ROZETI: gonderim icin zorunlu alanlar (unvan/VKN/vergi dairesi/adres/il)
 * eksikse listede gorunur - eksik bilgi ancak fatura gonderilirken fark ediliyordu.
 */
export function FirmaBilgileri() {
  const [subeler, setSubeler] = useState<ListeSatiri[]>([]);
  // KART KENDİ SEKMESİNDE (kullanıcı 25.10.2026: "firma şubeler listesinde kart aç deyince sekmede açılsın"):
  //   /sube/:id (SubeKarti) - projenin kart sekmesi deseni; kaydedince liste LISTE_TAZELE_OLAYI ile tazelenir.
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const git = useNavigate();
  const setKart = (id: number | 'yeni') => {
    const yol = `/sube/${id}`;
    if (ekranSekmesi) ekranSekmesi.kartaGit(yol); else git(yol);
  };
  // Listede secili sube (228): satira tiklayinca isaretlenir; ust ikonlar
  //   (duzenle/sil) secili satiri kullanir.
  const [seciliSube, setSeciliSube] = useState<number | null>(null);
  const [yukleniyor, setYukleniyor] = useState(true);
  const [hata, setHata] = useState<string | null>(null);

  const yukle = useCallback(async () => {
    setYukleniyor(true);
    try {
      const s = await api.liste('sube', {
        boyut: 200, sirala: [{ alan: 'varsayilan', yon: 'desc' }],
      });
      setSubeler(s.satirlar);
      setHata(null);
    } catch (h) {
      setHata(hataMetni(h));
    } finally {
      setYukleniyor(false);
    }
  }, []);

  useEffect(() => { void yukle(); }, [yukle]);
  useEffect(() => {
    const dinle = (e: Event) => { if ((e as CustomEvent).detail === SUBE_KAYNAGI) void yukle() };
    window.addEventListener(LISTE_TAZELE_OLAYI, dinle);
    return () => window.removeEventListener(LISTE_TAZELE_OLAYI, dinle);
  }, [yukle]);

  const eksikSube = subeler.filter(s => String(s.ebelgeHazir ?? '') !== 'Tamam').length;

  /** Secili subeyi siler - sunucu engelleri (belge/kullanici bagi) mesajla doner. */
  const subeSil = async (id: number) => {
    const ad = String(subeler.find(x => Number(x.id) === id)?.ad ?? id);
    // Uygulama penceresi (tarayici confirm'i "localhost diyor ki" basligiyla
    //   cikiyordu, kullanici).
    if (!await onay(`"${ad}" şubesi silinecek. Onaylıyor musunuz?`, true)) return;
    try {
      await api.kartSil('sube', id);
      setSeciliSube(null);
      void yukle();
    } catch (h) {
      setHata(hataMetni(h));
    }
  };


  return (
    <>
      <div className="sayfabas" style={{ marginBottom: 10 }}>
        <div className="basrow">
          <h1>Firma / Şubeler</h1>
          <span className="yol">{c('Yönetim › Firma / Şubeler')}</span>
        </div>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}
      {yukleniyor && <div className="yukleniyor">Yükleniyor…</div>}

      {!yukleniyor && (
        <div className="kagrup">
          <div className="numaralama-bas bitisik">
            <h6>Şube Tanımları</h6>
            {/* Ekle / Duzenle / Sil IKON olarak ustte (kullanici). */}
            <button className="d bir" title={c('Yeni Şube')}
                    onClick={() => setKart('yeni')}>＋</button>
            <button className="d" title="Düzenle" disabled={seciliSube === null}
                    onClick={() => seciliSube !== null && setKart(seciliSube)}>✎</button>
            <button className="d" title="Sil" disabled={seciliSube === null}
                    onClick={() => { if (seciliSube !== null) void subeSil(seciliSube) }}>🗑</button>
          </div>

          {/* e-Belge icin bilgisi eksik sube varsa ustte uyari: gonderim o
              subeden yapilamaz ve sebebi ancak fatura kesilirken anlasilirdi. */}
          {eksikSube > 0 && (
            <div className="hata-kutusu">
              {eksikSube} şubede e-Belge için zorunlu bilgiler eksik (ünvan, VKN,
              vergi dairesi, adres, il). O şubeden fatura gönderilemez.
            </div>
          )}

          <table className="grid">
            <thead>
              <tr>
                <th style={{ width: 34 }}></th>
                <th>Kod</th><th>{c('Şube Adı')}</th><th>Ünvan</th>
                <th>{c('İlçe / İl')}</th><th>Telefon</th>
                <th style={{ textAlign: 'center' }}>{c('Vars.')}</th>
                <th style={{ textAlign: 'center' }}>e-Belge</th>
                <th style={{ textAlign: 'center' }}>Durum</th>
              </tr>
            </thead>
            <tbody>
              {subeler.map(s => (
                /* Tek tik SATIRI ISARETLER (check), cift tik karti acar. */
                <tr key={String(s.id)}
                    className={seciliSube === Number(s.id) ? 'secili' : undefined}
                    style={{ cursor: 'pointer' }}
                    onClick={() => setSeciliSube(t =>
                      t === Number(s.id) ? null : Number(s.id))}
                    onDoubleClick={() => setKart(Number(s.id))}>
                  <td style={{ textAlign: 'center' }}>
                    <input type="checkbox" checked={seciliSube === Number(s.id)}
                           readOnly />
                  </td>
                  <td>{String(s.kod ?? '')}</td>
                  <td>{String(s.ad ?? '')}</td>
                  <td>{String(s.unvan ?? '')}</td>
                  <td>{[s.ilce, s.il].filter(Boolean).join(' / ')}</td>
                  <td>{String(s.telefon ?? '')}</td>
                  <td style={{ textAlign: 'center' }}>{Number(s.varsayilan) === 1 ? '✓' : ''}</td>
                  <td style={{ textAlign: 'center' }}>
                    <span className={`rozet ${String(s.ebelgeHazir) === 'Tamam' ? 'ok' : 'uyari'}`}>
                      {String(s.ebelgeHazir ?? '')}
                    </span>
                  </td>
                  <td style={{ textAlign: 'center' }}>
                    <span className={`rozet ${Number(s.aktif) === 1 ? 'ok' : 'gri'}`}>
                      {Number(s.aktif) === 1 ? 'Aktif' : 'Pasif'}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          <div className="not">
            Satıra tıklayınca seçilir, çift tıklayınca kart açılır. <b>{c('Baz Alınacak Şube')}</b> seçiliyse şubenin faturası o şubenin ünvanı ve VKN’siyle, kendi adresiyle gider.
          </div>
        </div>
      )}

    </>
  );
}

/**
 * ŞUBE KARTI - KENDİ EKRAN SEKMESİNDE (/sube/:id, kullanıcı 25.10.2026). Projenin kart sekmesi deseni:
 * çerçevesiz (sayfaKipi), sekme başlığı şubenin adı / "Yeni Şube"; Kaydet ve Kapat sekmeyi kapatır, sekme ×
 * kayıtsız değişikliği sorar (GenForm sayfa kipi). Kaydedince Firma / Şubeler listesi tazelenir.
 */
export function SubeKarti() {
  const { id: ham } = useParams();
  const id: number | 'yeni' = ham === 'yeni' ? 'yeni' : Number(ham);
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const git = useNavigate();
  /** e-Belge sekmesinin acik alt sekmesi (kart her acildiginda Genel'den baslar). */
  const [ebelgeAlt, setEbelgeAlt] = useState<string>('genel');
  /** Sekme başlığı = şubenin kısa adı (yüklenince); yeni kayıtta "Yeni Şube". */
  const [ad, setAd] = useState('');
  useEffect(() => {
    ekranSekmesi?.baslik(id === 'yeni' ? 'Yeni Şube' : ad ? sekmeAdi(ad) : 'Şube Kartı', `/sube/${ham}`);
  }, [ekranSekmesi, id, ham, ad]);
  const kapat = () => { if (ekranSekmesi) ekranSekmesi.kapat(); else git('/sube') };

  /**
   * Kartin "e-Belge" sekmesine ALT SEKME cubugu takar (kullanici): Genel /
   * Seri Bilgileri / XSLT / tur ayarlari. Genel kartin kendi alanlaridir
   * (gonderici, mukellef hesabi, test ortami, mukellefiyet); digerleri
   * Ayarlar ekranindan tasinan bolumler.
   *
   * YENI kayitta yalniz Genel calisir: seri/XSLT/tur ayarlari kartin id'sine
   * bagli olmasa da, once subenin kaydedilmesi akisi anlasilir kiliyor.
   */
  const ebelgeSekmesi = (sekmeBasligi: string, icerik: React.ReactNode,
                         deger: Record<string, unknown>) => {
    if (sekmeBasligi !== 'e-Belge') return icerik;
    // Mukellefiyet bayragi kartin GUNCEL degerinden okunur: kutu isaretlenince
    //   sekme kaydetmeyi beklemeden gorunur.
    const gorunur = EBELGE_ALT.filter(
      b => !('mukellefAlani' in b) || Boolean(deger[b.mukellefAlani]));
    // Acik sekme gizlendiyse Genel'e don - yoksa bos icerik kalirdi.
    const acik = gorunur.some(b => b.anahtar === ebelgeAlt) ? ebelgeAlt : 'genel';
    return (
      <>
        {/* Alt bolumler BUTON gorunumunde (kullanici) - sekme cizgisi ana
            sekmelerle karisiyordu. */}
        <div style={{ display: 'flex', gap: 6, margin: '-6px 0 8px' }}>
          {gorunur.map(b => (
            <button key={b.anahtar} type="button"
                    className={`d${b.anahtar === acik ? ' bir' : ''}`}
                    onClick={() => setEbelgeAlt(b.anahtar)}>
              {b.baslik}
            </button>
          ))}
        </div>
        {acik === 'genel' && icerik}
        {acik === 'seri' && <SeriKurallari />}
        {acik === 'xslt' && <XsltSablonlari />}
        {(['efatura', 'earsiv', 'eirsaliye', 'esmm'] as EBelgeTuru[]).includes(acik as EBelgeTuru)
          && <TurAyarlari tur={acik as EBelgeTuru} />}
      </>
    );
  };

  return (
    <GenForm key={String(id)} kaynak="sube" id={id} sayfaKipi
             baslik={id === 'yeni' ? 'Yeni Şube' : 'Firma / Şube'}
             seritAlanlari={SERIT_ALANLARI}
             sekmeSarmalayici={ebelgeSekmesi}
             onYuklendi={d => setAd(String(d.ad || d.unvan || ''))}
             onKapat={kapat}
             onKaydedildi={() => { window.dispatchEvent(new CustomEvent(LISTE_TAZELE_OLAYI, { detail: SUBE_KAYNAGI })); kapat() }} />
  );
}
