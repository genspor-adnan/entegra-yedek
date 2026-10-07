import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import type { EnabizErisimi } from '../api/uclar/enabiz';
import { EnabizButonu } from './EnabizButonu';
import { c as cev } from '../dil/ceviri';

const c = (m: string) => cev(m, 'etiket');

/**
 * MUAYENEDE e-NABIZ — hekimin hastanın DIŞ KURUM kayıtlarına bakma sekmesi
 * (mockup: Ekranlar/Muayene/muayene_enabiz_paneli_v3.html).
 *
 * <b>Veri bize AKMAZ, sayfa Bakanlıkta açılır.</b> Akış: `DoktorEHRErisimi`
 * çağrılır, dönen geçici `AccessKey` paylaşım adresinin sonuna eklenir ve
 * adres açılır; hekim orada e-Devlet ile girer, hasta verisini gizlemişse
 * hastaya SMS onayı gider. Bakanlık HBYS'ye hasta geçmişi döndürmediği için
 * bu sekmede tablo YOKTUR - sahte sütunlar çizmek "veri gelmiyor" gerçeğini
 * gizlemek olurdu.
 *
 * <b>Sayfa çerçeveye alınmaz.</b> İlk tasarımda gömülü pencere vardı; devlet
 * sayfaları `X-Frame-Options` ile çerçevelenmeye izin vermiyor ve hekim boş
 * bir kutu görüyordu. Bu yüzden adres yeni sekmede açılır (düğme zaten
 * tarayıcı pop-up kuralına uygun: sekme istekten ÖNCE açılıyor).
 *
 * Sekmenin işi üç şey: <b>erişimi başlatmak</b>, hekimin orada gördüğünü
 * <b>muayeneye aktarmasını kolaylaştırmak</b> ve <b>erişim kaydını</b>
 * (KVKK) aynı ekranda göstermek.
 */
export function MuayeneEnabizSekmesi({ hastaId, muayeneId, eylemler }: {
  hastaId: number;
  muayeneId: number;
  /** Aktarım kısayolları: kartın kendi ekleme yolları çağrılır, ikinci bir
      kayıt yolu açılmaz (tanı/ilaç kuralları tek yerde kalsın). */
  eylemler?: { taniEkle?: () => void; ilacEkle?: () => void; notaYaz?: () => void };
}) {
  const [erisimler, setErisimler] = useState<EnabizErisimi[] | null>(null);
  const [hata, setHata] = useState('');

  const yukle = useCallback(() => {
    if (!hastaId) { setErisimler([]); return }
    api.enabizErisimGecmisi(hastaId)
      .then(y => setErisimler(y.erisimler))
      .catch(h => { setHata(hataMetni(h)); setErisimler([]) });
  }, [hastaId]);

  useEffect(yukle, [yukle]);

  if (!hastaId) return (
    <div className="ic sonuk" style={{ padding: 12 }}>
      {c('Hasta bilgisi yüklenmeden e-Nabız erişimi açılamaz.')}
    </div>
  );

  return (
    <div className="mn-enabiz">
      <div className="me-ust">
        {/* DÜĞME ORTAK BİLEŞEN: görünüm, konum ve ipucu denetim (KTS H8)
            maddesidir, burada yeniden çizilmez. */}
        <EnabizButonu tur="erisim" hastaId={hastaId} muayeneId={muayeneId} />
        <EnabizButonu tur="mesaj" hastaId={hastaId} muayeneId={muayeneId} />
        <span className="mn-bosluk" />
        <button type="button" className="d" onClick={yukle}>↻ {c('Kayıtları yenile')}</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="me-akis">
        <div className="me-ad"><span className="no">1</span>
          <b>{c('Erişim isteği')}</b>
          <span>{c('Hekimin kimliği ve hastanın TCKN’si ile Bakanlık servisine istek gider.')}</span></div>
        <div className="me-ad"><span className="no">2</span>
          <b>{c('Geçici anahtar')}</b>
          <span>{c('Dönen anahtar saklanmaz; kayda yalnız ilk 8 karakteri girer.')}</span></div>
        <div className="me-ad"><span className="no">3</span>
          <b>{c('e-Nabız sayfası')}</b>
          <span>{c('Adres yeni sekmede açılır. Sayfa Bakanlığın sunucusunda çalışır.')}</span></div>
        <div className="me-ad"><span className="no">4</span>
          <b>{c('e-Devlet + SMS')}</b>
          <span>{c('Hekim orada e-Devlet ile girer; hasta kayıtlarını gizlemişse SMS onayı istenir.')}</span></div>
      </div>

      <div className="me-bilgi">
        {c('Hastanın bütün kurumlardaki tanı, ilaç, tahlil, görüntüleme ve epikriz '
          + 'bilgisi e-Nabız sayfasında görünür; bu ekrana veri olarak gelmez. Kendi '
          + 'muayenenize almak istediğinizi aşağıdaki kısayollarla kaydedin - kayıt '
          + '"hekim beyanı" olarak işaretlenir.')}
      </div>

      {eylemler && (
        <div className="me-aktar">
          <div className="me-bas">{c('Gördüğünü muayeneye aktar')}</div>
          <div className="me-dugmeler">
            {eylemler.taniEkle && (
              <button type="button" className="d" onClick={eylemler.taniEkle}>
                ➕ {c('Tanı ekle')}</button>
            )}
            {eylemler.ilacEkle && (
              <button type="button" className="d" onClick={eylemler.ilacEkle}>
                ➕ {c('İlaç ekle')}</button>
            )}
            {eylemler.notaYaz && (
              <button type="button" className="d" onClick={eylemler.notaYaz}>
                ✎ {c('Muayene notuna yaz')}</button>
            )}
          </div>
          <div className="sonuk me-ipucu">
            {c('Dış kurumda yapılan tahlil, kendi laboratuvar sonucunuz olarak '
              + 'kaydedilmez: muayene notuna kaynağı ve tarihiyle yazılır.')}
          </div>
        </div>
      )}

      <div className="me-bas">{c('Erişim kayıtları')}
        <span className="sonuk"> · {c('KVKK izi; başarısız denemeler de yazılır')}</span></div>
      {erisimler === null ? (
        <div className="ic sonuk" style={{ padding: 10 }}>{c('yükleniyor')}…</div>
      ) : erisimler.length === 0 ? (
        <div className="ic sonuk" style={{ padding: 10 }}>
          {c('Bu hastanın kayıtlarına henüz erişilmedi.')}
        </div>
      ) : (
        <div className="me-tablo">
          <table>
            <thead><tr>
              <th>{c('Zaman')}</th><th>{c('Hekim')}</th><th>{c('Sonuç')}</th>
              <th>{c('Anahtar')}</th><th>{c('Servis mesajı')}</th>
            </tr></thead>
            <tbody>
              {erisimler.map(e => (
                <tr key={e.id}>
                  <td>{new Date(e.zaman).toLocaleString('tr-TR')}</td>
                  <td>{e.hekim}</td>
                  <td>
                    <span className={`rozet ${e.sonuc === 1 ? 'olumlu'
                                     : e.sonuc === 0 ? 'gri' : 'olumsuz'}`}>
                      {e.sonucAdi}</span>
                  </td>
                  <td style={{ fontFamily: "Consolas, monospace" }}>{e.anahtarOnek || '—'}</td>
                  <td>{e.servisMesaji || '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
