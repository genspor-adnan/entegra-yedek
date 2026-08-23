import { useCallback, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import { ApiHatasi, type StokHareketYaniti } from '../api/sozlesme';

const say = new Intl.NumberFormat('tr-TR', { maximumFractionDigits: 4 });
const gun = (t: string) => new Date(t).toLocaleDateString('tr-TR');

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
  const bugun = new Date().toISOString().slice(0, 10);

  const [bas, setBas] = useState(`${yil}-01-01`);
  const [bit, setBit] = useState(bugun);
  const [depoId, setDepoId] = useState<number | null>(null);
  const [depolar, setDepolar] = useState<{ id: number; ad: string }[]>([]);
  const [veri, setVeri] = useState<StokHareketYaniti | null>(null);
  const [yukleniyor, setYukleniyor] = useState(true);
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
      setHata(h instanceof ApiHatasi ? h.message : String(h));
    } finally { setYukleniyor(false) }
  }, [stokId, bas, bit, depoId]);

  useEffect(() => { void yukle() }, [yukle]);

  function csvIndir() {
    const basliklar = ['Tarih', 'Belge', 'Belge No', 'Cari', 'Depo', 'Giriş', 'Çıkış', 'Kalan', 'Açıklama'];
    const satirlar = (veri?.satirlar ?? []).map(s => [
      gun(s.tarih), s.belgeTurAdi, s.belgeNo, s.tarafUnvan, s.depo,
      s.giris ? say.format(s.giris) : '', s.cikis ? say.format(s.cikis) : '',
      say.format(s.kalan), s.aciklama,
    ]);
    // Excel-TR: ayirac ";" ve UTF-8 BOM (yoksa Turkce karakterler bozuluyor).
    const metin = '﻿' + [basliklar, ...satirlar]
      .map(r => r.map(h => `"${String(h).replace(/"/g, '""')}"`).join(';')).join('\r\n');
    const bag = document.createElement('a');
    bag.href = URL.createObjectURL(new Blob([metin], { type: 'text/csv;charset=utf-8' }));
    bag.download = `stok_hareket_${stokId}_${bas}_${bit}.csv`;
    bag.click();
    URL.revokeObjectURL(bag.href);
  }

  const birim = veri?.birim ? ` ${veri.birim}` : '';

  return (
    <>
      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="kagrup">
        <h6>Son Stok Hareketleri</h6>

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
            Devir: <b>{say.format(Number(veri?.devir ?? 0))}</b> ·
            Kapanış: <b>{say.format(Number(veri?.kapanis ?? 0))}{birim}</b>
          </span>
        </div>

        {yukleniyor ? <div className="yukleniyor">Yükleniyor…</div> : (
          <table className="detay-tablo">
            <thead>
              <tr>
                <th style={{ width: 90 }}>Tarih</th>
                <th style={{ width: 200 }}>Belge</th>
                <th style={{ width: 70 }}>Tür</th>
                <th>Depo / Cari</th>
                <th className="hiza-sag" style={{ width: 85 }}>Giriş</th>
                <th className="hiza-sag" style={{ width: 85 }}>Çıkış</th>
                <th className="hiza-sag" style={{ width: 90 }}>Kalan</th>
              </tr>
            </thead>
            <tbody>
              <tr className="devir-satiri">
                <td colSpan={6}><i>Devir (aralıktan önce)</i></td>
                <td className="hiza-sag"><b>{say.format(Number(veri?.devir ?? 0))}</b></td>
              </tr>
              {(veri?.satirlar ?? []).map((s, i) => (
                // Cift tik: hareketi ureten belgeyi ac (ekstre satirlarindaki kural).
                <tr key={`${s.belgeId}:${i}`}
                    onDoubleClick={() => { const y = BELGE_YOLU[s.belgeTur]; if (y) git(`${y}/${s.belgeId}`) }}
                    title="Çift tıkla: belgeyi aç">
                  <td>{gun(s.tarih)}</td>
                  <td>{s.belgeTurAdi} <b>{s.belgeNo}</b></td>
                  <td>
                    <span className={`rozet ${s.yon === 'giris' ? 'ok'
                                            : s.yon === 'transfer' ? 'bilgi' : 'hata'}`}>
                      {s.yon === 'giris' ? 'Giriş' : s.yon === 'transfer' ? 'Transfer' : 'Çıkış'}
                    </span>
                  </td>
                  <td>{s.depo}{s.tarafUnvan ? <span className="soluk"> · {s.tarafUnvan}</span> : null}</td>
                  <td className="hiza-sag">{s.giris ? say.format(s.giris) : ''}</td>
                  <td className="hiza-sag">{s.cikis ? say.format(s.cikis) : ''}</td>
                  <td className="hiza-sag">{say.format(s.kalan)}</td>
                </tr>
              ))}
              {(veri?.satirlar ?? []).length === 0 && (
                <tr><td colSpan={7} className="bos">Bu aralıkta hareket yok.</td></tr>
              )}
            </tbody>
            <tfoot>
              <tr className="genel">
                <td colSpan={4}>{(veri?.satirlar ?? []).length} hareket</td>
                <td className="hiza-sag">{say.format((veri?.satirlar ?? []).reduce((t, s) => t + Number(s.giris), 0))}</td>
                <td className="hiza-sag">{say.format((veri?.satirlar ?? []).reduce((t, s) => t + Number(s.cikis), 0))}</td>
                <td className="hiza-sag"><b>{say.format(Number(veri?.kapanis ?? 0))}</b></td>
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
