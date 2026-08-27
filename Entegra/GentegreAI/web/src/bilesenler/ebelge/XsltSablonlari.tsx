import { useRef, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni, type ListeSatiri } from '../../api/sozlesme';
import { GenGrid } from '../GenGrid';
import { Modal } from '../Modal';
import { dosyaIndirUrl } from '../indir';

/**
 * XSLT SABLONLARI — belge GIB'e XML gider, insanin gordugu goruntu bu sablon
 * uygulanarak uretilir ve gonderimde XML'in ICINE gomulur (166).
 *
 * Sablonlar merkezi `dokuman` deposunda (160): ad, boyut, hash, varsayilan ve
 * yukleme/indirme altyapisi orada hazir - ayri tablo acilmadi.
 *
 * Ayarlar ekranindan Firma Bilgileri'ne TASINDI (kullanici): sablon da seri gibi
 * mukellefin gonderim kurulumunun parcasi.
 */
export function XsltSablonlari() {
  const [yenile, setYenile] = useState(0);
  const [secili, setSecili] = useState<ListeSatiri | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  /**
   * EKLEME FORMU (kullanici): "+ ya basinca klasorden dokuman secsin, adini ad
   * olarak kullansin ve ekleme formunu acsin; bilgileri orada girip kaydet
   * deyince bir satir olarak eklesin."
   *
   * Tur/yon secicileri baslikta DEGIL formda: yukleme oradan yapiliyor,
   * baslikta durmalari "hangi secim neyi etkiliyor" belirsizligi yaratiyordu.
   */
  const [form, setForm] = useState<
    { dosya?: File; id?: number; eskiTur?: number;
      ad: string; tur: number; yon: number; varsayilan: boolean } | null>(null);
  const dosyaGirdisi = useRef<HTMLInputElement | null>(null);

  const sil = async () => {
    if (!secili) return;
    if (!window.confirm(`"${secili.ad ?? ''}" şablonu silinecek. Onaylıyor musunuz?`)) return;
    setHata(null);
    try {
      await api.dokumanSil('ebelge-xslt', Number(secili.turKodu ?? 0), Number(secili.id));
      setSecili(null);
      setYenile(t => t + 1);
    } catch (h) { setHata(hataMetni(h)) }
  };

  /** Klasorden dosya secildi: formu DOSYA ADIYLA doldurup ac - kayit sonra. */
  const dosyaSecildi = (dosya: File | undefined) => {
    if (!dosya) return;
    setHata(null);
    setForm({ dosya, ad: dosya.name, tur: 1, yon: 2, varsayilan: false });
  };

  /** Secili satiri formda ac - dosya degismez, yalniz bilgileri duzenlenir. */
  const duzenle = (satir?: ListeSatiri) => {
    const s = satir ?? secili;
    if (!s) return;
    const tur = Number(s.turKodu ?? 0);
    setHata(null);
    setForm({
      id: Number(s.id), eskiTur: tur,
      ad: String(s.ad ?? ''),
      tur: tur || 1,
      yon: String(s.yon) === 'Gelen' ? 1 : 2,
      varsayilan: Boolean(s.varsayilan),
    });
  };

  /** Yeni sablonu ekler ya da acik satiri gunceller. */
  const kaydet = async () => {
    if (!form) return;
    setHata(null);
    try {
      if (form.id) {
        await api.dokumanDuzenle('ebelge-xslt', form.eskiTur ?? form.tur, form.id,
          form.ad.trim(), '',
          { kaynakId: form.tur, yon: form.yon, varsayilan: form.varsayilan });
      } else if (form.dosya) {
        // Ad degistirildiyse dosyayi o adla gonder - satirin adi dosya adindan gelir.
        const dosya = form.ad.trim() && form.ad !== form.dosya.name
          ? new File([form.dosya], form.ad.trim(), { type: form.dosya.type })
          : form.dosya;
        await api.dokumanYukle('ebelge-xslt', form.tur, dosya, form.varsayilan, form.yon);
      }
      setForm(null);
      setSecili(null);
      setYenile(t => t + 1);
    } catch (h) { setHata(hataMetni(h)) }
  };

  /**
   * Secili sablonu diske kaydet. Icerik yetkili istekle cekilir (blob URL);
   * dosya adi sablonun adidir, uzantisi yoksa .xslt eklenir.
   */
  const indir = async () => {
    if (!secili) return;
    setHata(null);
    try {
      const url = await api.dokumanIcerikUrl(Number(secili.id));
      const ad = String(secili.ad ?? 'sablon');
      dosyaIndirUrl(url, /\.(xsl|xslt|xml)$/i.test(ad) ? ad : `${ad}.xslt`, true);
    } catch (h) { setHata(hataMetni(h)) }
  };

  return (
    <>
      <div className="kagrup">
        <div className="numaralama-bas bitisik">
          <h6>XSLT Şablonları</h6>
          <span className="baslik-eylem">
            {/* Dosya secici gizli: "＋" ona basar, secilen DOSYANIN ADI forma
                ad olarak dolar. */}
            <input ref={dosyaGirdisi} type="file" accept=".xsl,.xslt,.xml" hidden
                   onChange={e => {
                     dosyaSecildi(e.target.files?.[0]);
                     e.target.value = '';        // ayni dosya tekrar secilebilsin
                   }} />
            <button className="d bir ikon-dugme" title="Klasörden şablon seç"
                    onClick={() => dosyaGirdisi.current?.click()}>＋</button>
            <button className="d ikon-dugme" disabled={!secili}
                    title={secili ? 'Seçili şablonun bilgilerini düzenle' : 'Önce satır seçin'}
                    onClick={() => duzenle()}>✎</button>
            <button className="d teh ikon-dugme" disabled={!secili}
                    title={secili ? 'Seçili şablonu sil' : 'Önce satır seçin'}
                    onClick={() => { void sil() }}>🗑</button>
            <button className="d ikon-dugme" disabled={!secili}
                    title={secili ? 'Seçili şablonu dosyaya kaydet' : 'Önce satır seçin'}
                    onClick={() => { void indir() }}>💾</button>
          </span>
        </div>
        {hata && <div className="hata-kutusu">{hata}</div>}
        <GenGrid
          key={`ebelge-xslt-${yenile}`}
          kaynak="ebelge-xslt"
          gomulu
          seritGizli
          boyut={25}
          onSecimDegisti={setSecili}
          onSatirAc={satir => { setSecili(satir); duzenle(satir); }}
        />
        <div className="not">
          Belge GİB'e XML olarak gider; insanın gördüğü görüntü bu şablon
          uygulanarak üretilir ve gönderimde XML'in <b>içine gömülür</b>.
          <b> ＋</b> ile klasörden seçtiğiniz dosyanın adı şablon adı olur;
          <b> 💾</b> seçili şablonu diske kaydeder. Her belge türü ve yön için
          <b> bir</b> şablon varsayılan olabilir.
        </div>
      </div>

      {form && (
        <Modal
          baslik={form.id ? 'XSLT Şablonu' : 'XSLT Şablonu Ekle'}
          dar
          onKapat={() => setForm(null)}
          alt={<>
            <button className="d kapat-dugmesi" onClick={() => setForm(null)}>Vazgeç</button>
            <button className="d bir" disabled={!form.ad.trim()}
                    onClick={() => { void kaydet() }}>Kaydet</button>
          </>}
        >
          <div className="kagrup">
            <div className="alan-izgara tek-sutun ayar-formu">
              <label className="alan">
                <span className="etiket zorunlu-isaret">Şablon Adı</span>
                <span className="ikili">
                  <input className="genis-deger" value={form.ad}
                         onChange={e => setForm({ ...form, ad: e.target.value })} />
                </span>
              </label>
              <label className="alan">
                <span className="etiket">e-Belge Türü</span>
                <span className="ikili">
                  <select value={form.tur}
                          onChange={e => setForm({ ...form, tur: Number(e.target.value) })}>
                    <option value={1}>e-Fatura</option>
                    <option value={2}>e-Arşiv</option>
                    <option value={7}>e-İrsaliye</option>
                    <option value={8}>e-SMM</option>
                  </select>
                </span>
              </label>
              <label className="alan">
                <span className="etiket">Yön</span>
                <span className="ikili">
                  <select value={form.yon}
                          onChange={e => setForm({ ...form, yon: Number(e.target.value) })}>
                    <option value={2}>Giden</option>
                    <option value={1}>Gelen</option>
                  </select>
                </span>
              </label>
              <label className="alan ayar-onay">
                <input type="checkbox" checked={form.varsayilan}
                       onChange={e => setForm({ ...form, varsayilan: e.target.checked })} />
                <span className="etiket">Bu tür ve yön için varsayılan olsun</span>
              </label>
            </div>
          </div>
        </Modal>
      )}
    </>
  );
}
