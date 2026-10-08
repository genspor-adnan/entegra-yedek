import { useCallback, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { KUPURLER, type KupurSatiri, type UygunBanko } from '../../api/uclar/bankoOturum';
import { mesaj } from '../mesaj';

/**
 * OTURUM AÇ MODALI (kullanıcı 08.10.2026: "bankolar a oturum aç butonu ekle
 * ve bu modal i açsın").
 *
 * Bankolar listesinden açılır: görevli sabah bankosunu listede buluyor,
 * oradan vardiyayı başlatmak menüden ikinci ekrana gidip bankoyu yeniden
 * seçmekten kısa. Modal YALNIZ AÇILIŞI yapar; gün içi şerit, gün sonu sayımı
 * ve teslim tam sayfa akış ekranının işi (`/banko-oturum`) - altı adımı
 * modala sıkıştırmak hepsini daraltırdı.
 *
 * DEVİR SUNUCUDAN gelir ve yazılamaz (`fn_banko_devir` - önceki oturumun
 * kasada bıraktığı tutar). Görevli yalnız SAYIMI girer; farkı sunucu hesaplar
 * ve açılışa yazar - sonraki görevli başkasının farkını devralmasın.
 */
export function OturumAcModali({ bankoId, onKapat }: {
  bankoId: number;
  onKapat(acildi: boolean): void;
}) {
  const git = useNavigate();
  const [bankolar, setBankolar] = useState<UygunBanko[] | null>(null);
  const [vardiya, setVardiya] = useState('');
  const [kupur, setKupur] = useState<Record<number, string>>({});
  const [tutar, setTutar] = useState('');
  const [not, setNot] = useState('');
  const [hata, setHata] = useState('');
  const [bekle, setBekle] = useState(false);

  useEffect(() => {
    (async () => {
      try { setBankolar(await api.bankoOturumUygun()) }
      catch (h) { setHata(hataMetni(h)); setBankolar([]) }
    })();
  }, []);

  const banko = useMemo(
    () => bankolar?.find(b => b.id === bankoId) ?? null, [bankolar, bankoId]);

  const toplam = KUPURLER.reduce((t, b) => t + b * (parseInt(kupur[b] ?? '', 10) || 0), 0);
  const sayim = banko?.kupurDokumu ? toplam : (parseFloat(tutar.replace(',', '.')) || 0);
  const fark = banko ? sayim - banko.devir : 0;
  const kupurListe = (): KupurSatiri[] =>
    KUPURLER.map(b => ({ birim: b, adet: parseInt(kupur[b] ?? '', 10) || 0 }))
      .filter(x => x.adet > 0);

  // HATA MODAL İÇİNDE GÖSTERİLİR, dışarıdaki mesaj kutusunda değil: modal
  //   önde duruyor ve kullanıcı neyi düzelteceğini burada okumalı. Sunucunun
  //   reddi iş kuralıdır ("açık oturumunuz var", "pasif banko"), teknik hata
  //   değil - kapatıp kaybetmek yanlış olurdu.
  const ac = useCallback(async () => {
    if (!banko) return;
    setBekle(true); setHata('');
    try {
      const y = await api.bankoOturumAc({
        bankoId: banko.id, vardiya, acilisSayim: sayim, not,
        kupurler: banko.kupurDokumu ? kupurListe() : undefined,
      });
      if (y.mesaj) mesaj(y.mesaj);
      onKapat(true);
      // Açılıştan sonra akış ekranına geç: onay bekliyorsa bekleme kutusu,
      //   açıldıysa gün içi şerit orada - görevli kaldığı yerden sürdürür.
      git('/banko-oturum');
    } catch (h) { setHata(hataMetni(h)) }
    finally { setBekle(false) }
  }, [banko, vardiya, sayim, not, kupur, git, onKapat]);

  return (
    <div className="oam-ort" onClick={() => onKapat(false)}>
      <div className="oam" onClick={e => e.stopPropagation()}>
        <style>{stil}</style>
        <div className="oam-bas">
          🔓 Banko Oturumu Aç
          <button type="button" className="oam-kapat" onClick={() => onKapat(false)}>✖</button>
        </div>

        {bankolar === null ? (
          <div className="oam-ic sonuk">Yükleniyor…</div>
        ) : !banko ? (
          <div className="oam-ic">
            <div className="gp-hata oam-hata">
              {hata || 'Bu bankoda oturum açılamıyor.'}
            </div>
            <div className="oam-not">
              Olası sebepler: bankoda zaten <b>canlı bir oturum var</b>, banko
              <b> pasif</b>, <b>danışma</b> türünde (kasası yok), başka şubeye ait ya
              da <b>sizin başka bir açık oturumunuz var</b> (bir görevli aynı anda tek
              oturum).
            </div>
          </div>
        ) : (
          <>
            <div className="oam-ic">
              {hata && <div className="gp-hata oam-hata oam-uyari">{hata}</div>}
              <div className="oam-izgara">
                <label>Banko<input readOnly value={`${banko.kod} — ${banko.ad}`} /></label>
                <label>Kasa hesabı<input readOnly value={banko.hesap || '—'} /></label>
                <label>Vardiya
                  <input value={vardiya} onChange={e => setVardiya(e.target.value)}
                         placeholder="Sabah · 08:00–16:00" autoFocus /></label>
                <label>Sistem devri
                  <input readOnly className="oam-buyuk" value={para(banko.devir) + ' ₺'} /></label>
              </div>
              <div className="oam-not">
                Sistem devri <b>önceki oturumun kapanış bakiyesidir</b> ve elle
                değiştirilemez. Sayım farklıysa fark kapanışta değil <b>açılışta</b>
                yazılır.
              </div>
            </div>

            {banko.kupurDokumu ? (
              <table className="oam-kupur">
                <thead><tr><th>Kupür</th><th>Adet</th><th>Tutar</th></tr></thead>
                <tbody>
                  {KUPURLER.map(b => {
                    const adet = parseInt(kupur[b] ?? '', 10) || 0;
                    return (
                      <tr key={b}>
                        <td>{b === 1 ? 'Bozuk (₺)' : `${b} ₺`}</td>
                        <td><input value={kupur[b] ?? ''} inputMode="numeric"
                                   onChange={e => setKupur(o => ({ ...o, [b]: e.target.value }))} /></td>
                        <td>{para(b * adet)}</td>
                      </tr>
                    );
                  })}
                  <tr className="top"><td>Sayılan</td><td /><td>{para(toplam)}</td></tr>
                </tbody>
              </table>
            ) : (
              <div className="oam-ic">
                <label className="oam-tek">Kasada bulunan (sayım)
                  <input value={tutar} onChange={e => setTutar(e.target.value)}
                         className="oam-buyuk" placeholder="0,00" /></label>
              </div>
            )}

            <div className="oam-ic">
              <div className="oam-izgara">
                <label>Fark
                  <input readOnly className={'oam-buyuk' + (fark !== 0 ? ' oam-kir' : '')}
                         value={para(fark) + ' ₺'} /></label>
                <label className="oam-genis">
                  Not{fark !== 0 ? ' (fark var - açıklayın)' : ''}
                  <input value={not} onChange={e => setNot(e.target.value)} /></label>
              </div>
            </div>

            <div className="oam-alt">
              <button type="button" className="d birincil" disabled={bekle} onClick={ac}>
                {banko.acilisOnay ? '📨 Onaya Gönder' : '🔓 Oturumu Aç'}
              </button>
              <button type="button" className="d" onClick={() => onKapat(false)}>Vazgeç</button>
              <span className="oam-not">
                {banko.acilisOnay
                  ? 'Bu bankoda açılış sorumlu onayı istiyor; onay gelene kadar tahsilat girilemez.'
                  : 'Bu bankoda açılış onayı kapalı - devri sayıp doğrudan açılır.'}
              </span>
            </div>
          </>
        )}
      </div>
    </div>
  );
}

const para = (n: number) =>
  n.toLocaleString('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

const stil = `
.oam-ort { position:fixed; inset:0; background:rgba(16,28,42,.45); z-index:900;
  display:flex; align-items:flex-start; justify-content:center; padding:48px 16px; overflow:auto }
.oam { width:min(620px,100%); background:var(--kart,#fff); border:1px solid var(--cizgi,#cdd6e0);
  border-radius:8px; box-shadow:0 18px 48px rgba(16,28,42,.28); overflow:hidden }
.oam-bas { background:linear-gradient(#2b5c95,#1c4374); color:#fff; padding:9px 12px;
  font-weight:bold; font-size:13.5px; display:flex; align-items:center }
.oam-kapat { margin-left:auto; background:none; border:none; color:#fff; cursor:pointer; font-size:14px }
.oam-ic { padding:10px 12px }
.oam-izgara { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:8px 12px }
.oam-izgara label, .oam-tek { display:flex; flex-direction:column; gap:3px; font-size:11px;
  color:var(--ikincil-metin,#6b7a8b) }
.oam-izgara .oam-genis { grid-column:span 2 }
.oam-izgara input, .oam-tek input { border:1px solid var(--cizgi,#cdd6e0); border-radius:4px;
  padding:5px 7px; font-size:12.5px; background:var(--giris-arka,#fff); color:var(--metin,#1f2d3a) }
.oam-izgara input[readonly], .oam-tek input[readonly] { background:#f6f8fa }
.oam-buyuk { font-family:Consolas,monospace; font-weight:bold; text-align:right }
.oam-kir { color:#b3261e }
.oam-not { color:var(--ikincil-metin,#6b7a8b); font-size:11px; line-height:1.6; margin-top:6px }
.oam-hata { margin:0 0 6px }
.oam-uyari { background:#fbe9e7; border:1px solid #f3c4bf; color:#8c1d18;
  border-radius:6px; padding:8px 10px; font-size:12px; line-height:1.5 }
.oam-kupur { border-collapse:collapse; width:calc(100% - 24px); margin:0 12px; font-size:12px }
.oam-kupur th, .oam-kupur td { border-bottom:1px solid var(--cizgi-ince,#e3e9f0); padding:4px 7px }
.oam-kupur th:last-child, .oam-kupur td:last-child { text-align:right; font-family:Consolas,monospace }
.oam-kupur tr.top td { font-weight:bold; background:#f7f9fc }
.oam-kupur input { width:70px; border:1px solid var(--cizgi,#cdd6e0); border-radius:3px;
  padding:3px 6px; text-align:right; font-family:Consolas,monospace;
  background:var(--giris-arka,#fff); color:var(--metin,#1f2d3a) }
.oam-alt { display:flex; gap:8px; align-items:center; flex-wrap:wrap; padding:10px 12px;
  border-top:1px solid var(--cizgi-ince,#e3e9f0) }
@media (prefers-color-scheme: dark) {
  :root:not([data-tema="acik"]) .oam-izgara input[readonly] { background:rgba(255,255,255,.04) }
  :root:not([data-tema="acik"]) .oam-kupur tr.top td { background:rgba(255,255,255,.04) }
}
`;

export default OturumAcModali;
