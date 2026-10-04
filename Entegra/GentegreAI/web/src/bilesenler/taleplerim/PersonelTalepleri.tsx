import { useEffect, useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { TalepSatiri } from '../../api/uclar/izin';
import { tarihSaat } from '../bicim';
import { useOturum } from '../../kimlik/OturumBaglami';
import { c } from '../../dil/ceviri';
import { PERSONEL_TALEP_TURLERI, type PersonelTalepDurumu } from './personelTalebi';

/**
 * PERSONEL KARTI "TALEPLER" SEKMESİ (kullanıcı: "personel kartı içinde izinler
 * sekmesi var.. onun yerine Talepler sekmesi olsa ve tüm talepler sondan başa
 * doğru sıralı listelense").
 *
 * Kişinin izin, avans, masraf, belge, arıza ve malzeme talepleri tek listede,
 * en yeni üstte (sorgu Taleplerim ile ortak: TaleplerimUclari.TalepSorgusu).
 * Çift tık talebin kartını açar; Kapat personel kartına döner.
 */
const KART_YOLU: Record<string, string> = {
  izin: '/personel-izin', avans: '/personel-avans', masraf: '/personel-masraf', belge: '/personel-belge-talep',
};
const GRUP_RENGI: Record<string, string> = {
  taslak: 'tl-c-gri', onayda: 'tl-c-bek', acik: 'tl-c-mavi', tamam: 'tl-c-ok', red: 'tl-c-red', iptal: 'tl-c-gri',
};

export function PersonelTalepleri({ tarafId, ad }: { tarafId: number; ad: string }) {
  const git = useNavigate();
  const konum = useLocation();
  const { yetki } = useOturum();
  const [satirlar, setSatirlar] = useState<TalepSatiri[] | null>(null);
  const [hata, setHata] = useState<string | null>(null);

  useEffect(() => {
    api.personelTalepleri(tarafId).then(y => setSatirlar(y.satirlar)).catch(e => setHata(hataMetni(e)));
  }, [tarafId]);

  // Kart açılınca arkada personel listesi, Kapat'ta bu personel kartı.
  const durum: PersonelTalepDurumu = { personel: { id: tarafId, ad }, geri: konum.pathname + konum.search, arka: 'personel' };
  //   Kayıtlı talep kendi personelini okur - yalnız dönüş bilgisi gider.
  const ac = (yol: string, yeni = false) =>
    git(yol, { state: yeni ? durum : { geri: durum.geri, arka: durum.arka } });

  return (
    <div className="pt-sekme">
      <div className="pt-arac">
        <span className="sonuk">{satirlar ? `${satirlar.length} ${c('talep')} · ${c('en yeni üstte')}` : ''}</span>
        <span className="ck-bosluk" />
        {PERSONEL_TALEP_TURLERI.filter(t => yetki(t.yetki, 'ekle')).map(t => (
          <button key={t.kod} type="button" className="d mini" onClick={() => ac(`${t.yol}/yeni`, true)}>＋ {c(t.ad)}</button>
        ))}
      </div>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {!satirlar ? <div className="sonuk" style={{ padding: 12 }}>{c('yükleniyor')}…</div> : satirlar.length === 0 ? (
        <div className="sonuk" style={{ padding: 12 }}>{c('Bu personelin talebi yok.')}</div>
      ) : (
        <table className="pt-tablo">
          <thead><tr><th>{c('Tarih')}</th><th>{c('Tür')}</th><th>{c('No')}</th><th>{c('Ayrıntı')}</th>
            <th className="sag">{c('Tutar')}</th><th>{c('Durum')}</th></tr></thead>
          <tbody>
            {satirlar.map(s => {
              const yol = KART_YOLU[s.tur];
              return (
                <tr key={`${s.tur}-${s.id}`} className={yol ? 'pt-acilir' : undefined}
                    title={yol ? c('Çift tık: talebi aç') : undefined} onDoubleClick={() => yol && ac(`${yol}/${s.id}`)}>
                  <td>{tarihSaat(s.eklemeTarihi)}</td>
                  <td>{c(s.baslik)}</td>
                  <td>{s.no}</td>
                  <td className="pt-detay">{s.detay}{s.redNeden ? ` · ${s.redNeden}` : ''}</td>
                  <td className="sag">{s.tutar != null ? Number(s.tutar).toLocaleString('tr-TR', { minimumFractionDigits: 2 }) : ''}</td>
                  <td><span className={`tl-chip ${GRUP_RENGI[s.grup] ?? ''}`}>{c(s.durumAdi)}</span>
                    {s.adimAd && s.grup === 'onayda' && <small className="sonuk"> · {s.adimAd}</small>}</td>
                </tr>
              );
            })}
          </tbody>
        </table>
      )}
    </div>
  );
}
