import { useCallback, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import { type StokHareketSatiri, type StokHareketYaniti, hataMetni } from '../api/sozlesme';
import { say4, gunMetni, tarihSaat, bugunIso } from './bicim';
import { csvMetni, CSV_TIPI } from './csv';
import { dosyaIndir } from './indir';
import { c } from '../dil/ceviri';


/** Belge türünden liste/kart yolu - hareket satırına çift tıklayınca oraya gidilir. */
const BELGE_YOLU: Record<number, string> = {
  9: '/alis-siparis', 10: '/alis-irsaliye', 11: '/alis-fatura', 12: '/alis-fisi', 109: '/alis-konsinye',
  19: '/siparis', 14: '/satis-irsaliye', 15: '/belge', 16: '/satis-fisi', 119: '/satis-konsinye',
};

/**
 * Stok kartı "Hareketler" sekmesi — Ekranlar/stok_karti.html.
 *
 * SALT OKUNUR döküm: kaynağı belge satırlarıdır, buradan hareket eklenmez.
 * Yalnız STOĞU GERÇEKTEN OYNATAN satırlar listelenir - irsaliyeden türetilen
 * fatura satırı stoğu ikinci kez oynatmaz, dökümde de görünmez.
 *
 * Tarih aralığı varsayılanı hesap ekstresiyle aynı kural: içinde bulunulan yılın
 * 1 Ocak'ı → bugün (bugün dahil). Devir = aralıktan önceki net toplam.
 */
export function StokHareketSekmesi({ stokId }: { stokId: number }) {
  const git = useNavigate();
  const yil = new Date().getFullYear();
  const bugun = bugunIso();

  const [bas, setBas] = useState(`${yil}-01-01`);
  const [bit, setBit] = useState(bugun);
  const [depoId, setDepoId] = useState<number | null>(null);
  const [depolar, setDepolar] = useState<{ id: number; ad: string }[]>([]);
  const [veri, setVeri] = useState<StokHareketYaniti | null>(null);
  const [yukleniyor, setYukleniyor] = useState(true);
  /** BAŞLIKTAN SIRALAMA (kullanıcı 02.11.2026): tık artan, ikinci tık azalan, üçüncü tık ilk (tarih) sırası.
      Kalan sütunu sunucunun tarih sırasıyla yürüttüğü bakiyedir - sıralama onu değiştirmez. */
  const [sira, setSira] = useState<{ alan: keyof StokHareketSatiri; yon: 1 | -1 } | null>(null);
  const [hata, setHata] = useState<string | null>(null);

  useEffect(() => {
    void api.liste('depo', { sayfa: 1, boyut: 200, sirala: [{ alan: 'ad', yon: 'asc' }] })
      .then(y => setDepolar(y.satirlar.map(s => ({ id: Number(s.id), ad: String(s.ad ?? '') }))))
      .catch(() => setDepolar([]));
  }, []);

  const yukle = useCallback(async () => {
    setYukleniyor(true);
    try {
      setVeri(await api.stokHareket(stokId, bas, bit, depoId));
      setHata(null);
    } catch (h) {
      setHata(hataMetni(h));
    } finally { setYukleniyor(false) }
  }, [stokId, bas, bit, depoId]);

  useEffect(() => { void yukle() }, [yukle]);

  function csvIndir() {
    const basliklar = ['Tarih', 'Belge', 'Belge No', 'Cari', 'Depo', 'Giriş', 'Çıkış', 'Kalan', 'Açıklama'];
    const satirlar = (veri?.satirlar ?? []).map(s => [
      gunMetni(s.tarih), s.belgeTurAdi, s.belgeNo, s.tarafUnvan, s.depo,
      s.giris ? say4.format(s.giris) : '', s.cikis ? say4.format(s.cikis) : '',
      say4.format(s.kalan), s.aciklama,
    ]);
    dosyaIndir(csvMetni(basliklar, satirlar),
               `stok_hareket_${stokId}_${bas}_${bit}.csv`, CSV_TIPI);
  }

  const birim = veri?.birim ? ` ${veri.birim}` : '';

  const siraliSatirlar = useMemo(() => {
    const l = [...(veri?.satirlar ?? [])];
    if (!sira) return l;
    const { alan, yon } = sira;
    return l.sort((a, b) => {
      const x = a[alan], y = b[alan];
      const k = typeof x === 'number' && typeof y === 'number' ? x - y
        : String(x ?? '').localeCompare(String(y ?? ''), 'tr', { numeric: true });
      return k * yon;
    });
  }, [veri, sira]);
  const sirala = (alan: keyof StokHareketSatiri) => setSira(s =>
    !s || s.alan !== alan ? { alan, yon: 1 } : s.yon === 1 ? { alan, yon: -1 } : null);
  const isaret = (alan: keyof StokHareketSatiri) => sira?.alan === alan ? (sira.yon === 1 ? ' ▲' : ' ▼') : '';
  const sutunBasi = (alan: keyof StokHareketSatiri, metin: string, sinif?: string, genislik?: number) => (
    <th className={`siralanir${sinif ? ` ${sinif}` : ''}`} style={genislik ? { width: genislik } : undefined}
        title={c('Sırala')} onClick={() => sirala(alan)}>{metin}{isaret(alan)}</th>);

  return (
    <>
      {hata && <div className="hata-kutusu">{hata}</div>}

      {/* ÇERÇEVESİZ (kullanıcı 02.11.2026: "Son Stok Hareketleri ile başlayan çerçeveyi kaldır"): sekme adı
          zaten "Hareketler"; süzgeç şeridi ve tablo doğrudan sekmede (Stok Durumu ile aynı). */}
      <div className="stok-hareket">

        <div className="hareket-serit">
          <label className="satir-ici">
            📅 <input type="date" value={bas} onChange={e => setBas(e.target.value)} />
            – <input type="date" value={bit} onChange={e => setBit(e.target.value)} />
          </label>
          <label className="satir-ici">
            Depo:
            <select value={depoId ?? ''} onChange={e => setDepoId(e.target.value ? Number(e.target.value) : null)}>
              <option value="">Tümü</option>
              {depolar.map(d => <option key={d.id} value={d.id}>{d.ad}</option>)}
            </select>
          </label>
          <span className="hareket-ozet">
            Devir: <b>{say4.format(Number(veri?.devir ?? 0))}</b> ·
            Kapanış: <b>{say4.format(Number(veri?.kapanis ?? 0))}{birim}</b>
          </span>
        </div>

        {yukleniyor ? <div className="yukleniyor">Yükleniyor…</div> : (
          <table className="detay-tablo">
            <thead>
              <tr>
                {sutunBasi('tarih', c('Tarih'), undefined, 130)}
                {sutunBasi('belgeNo', c('Belge'), undefined, 200)}
                {sutunBasi('yon', c('Tür'), undefined, 70)}
                {sutunBasi('depo', c('Depo / Cari'))}
                {sutunBasi('giris', c('Giriş'), 'hiza-sag', 85)}
                {sutunBasi('cikis', c('Çıkış'), 'hiza-sag', 85)}
                {sutunBasi('kalan', c('Kalan'), 'hiza-sag', 90)}
              </tr>
            </thead>
            <tbody>
              <tr className="devir-satiri">
                <td colSpan={6}><i>{c('Devir (aralıktan önce)')}</i></td>
                <td className="hiza-sag"><b>{say4.format(Number(veri?.devir ?? 0))}</b></td>
              </tr>
              {siraliSatirlar.map((s, i) => (
                // Cift tik: hareketi ureten belgeyi ac (ekstre satirlarindaki kural).
                <tr key={`${s.belgeId}:${i}`}
                    onDoubleClick={() => { const y = BELGE_YOLU[s.belgeTur]; if (y) git(`${y}/${s.belgeId}`) }}
                    title={c('Çift tıkla: belgeyi aç')}>
                  {/* SAAT DE (kullanıcı 02.11.2026: "hareketlerde tarihte saat de görünsün"). */}
                  <td>{tarihSaat(s.tarih)}</td>
                  <td>{s.belgeTurAdi} <b>{s.belgeNo}</b></td>
                  <td>
                    <span className={`rozet ${s.yon === 'giris' ? 'ok'
                                            : s.yon === 'transfer' ? 'bilgi' : 'hata'}`}>
                      {s.yon === 'giris' ? 'Giriş' : s.yon === 'transfer' ? 'Transfer' : 'Çıkış'}
                    </span>
                  </td>
                  <td>{s.depo}{s.tarafUnvan ? <span className="soluk"> · {s.tarafUnvan}</span> : null}</td>
                  <td className="hiza-sag">{s.giris ? say4.format(s.giris) : ''}</td>
                  <td className="hiza-sag">{s.cikis ? say4.format(s.cikis) : ''}</td>
                  <td className="hiza-sag">{say4.format(s.kalan)}</td>
                </tr>
              ))}
              {(veri?.satirlar ?? []).length === 0 && (
                <tr><td colSpan={7} className="bos">{c('Bu aralıkta hareket yok.')}</td></tr>
              )}
            </tbody>
            <tfoot>
              <tr className="genel">
                <td colSpan={4}>{(veri?.satirlar ?? []).length} hareket</td>
                <td className="hiza-sag">{say4.format((veri?.satirlar ?? []).reduce((t, s) => t + Number(s.giris), 0))}</td>
                <td className="hiza-sag">{say4.format((veri?.satirlar ?? []).reduce((t, s) => t + Number(s.cikis), 0))}</td>
                <td className="hiza-sag"><b>{say4.format(Number(veri?.kapanis ?? 0))}</b></td>
              </tr>
            </tfoot>
          </table>
        )}

        <div className="gridtb">
          <button className="mini" onClick={csvIndir}
                  disabled={(veri?.satirlar ?? []).length === 0}>📊 CSV Kaydet</button>
        </div>
        <div className="not">
          Salt-okunur döküm: hareketler belgelerden gelir. İrsaliyeden türetilen fatura
          stoğu ikinci kez oynatmadığı için burada görünmez. Satıra çift tıklayınca
          hareketi üreten belge açılır.
        </div>
      </div>
    </>
  );
}
