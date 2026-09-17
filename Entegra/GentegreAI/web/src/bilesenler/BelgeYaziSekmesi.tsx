import { useState } from 'react';
import { GenGrid } from './GenGrid';
import { GenForm } from './GenForm';

/**
 * BELGE YAZILARI (768) — Genel Ayarlar › Belge Yazıları.
 *
 * Belge talebinde üretilen resmî yazının ŞABLONLARI. "Belge No"nun komşusu
 * olması tesadüf değil: ikisi de *belge nasıl çıksın* ayarı - biri numarayı,
 * öteki metni belirler.
 *
 * Gövde DÜZ METİNDİR; yer tutucular `{personel_ad}` biçiminde yazılır ve
 * `fn_belge_talep_yazi` çözer. Çözemediği yer tutucu metinde OLDUĞU GİBİ
 * kalır ve talebin yazı ekranında "eksik" olarak listelenir - sessizce
 * silmek, kâğıda boş bir satır bastırırdı.
 */
const YER_TUTUCULAR = [
  ['muhatap', 'Muhatap (boşsa “İlgili Makama,”)'],
  ['personel_ad', 'Personelin adı'],
  ['tc', 'T.C. kimlik no'],
  ['sicil', 'Sicil no'],
  ['gorev', 'Görevi'],
  ['ise_giris', 'İşe giriş tarihi'],
  ['calisma_sekli', 'Tam/yarı zamanlı'],
  ['sozlesme_turu', 'Sözleşme türü'],
  ['sgk_sicil', 'SGK sicil no'],
  ['amac', 'Talebin amacı'],
  ['talep_no', 'Talep numarası'],
  ['tarih', 'Bugünün tarihi'],
  ['maas', 'Maaş tutarı (talepte girilir)'],
  ['maas_turu', 'net / brüt'],
  ['para_birimi', 'Kurum para birimi'],
  ['kurum_unvan', 'Kurum unvanı'],
  ['kurum_adres', 'Kurum adresi'],
  ['kurum_il', 'İl'],
  ['kurum_ilce', 'İlçe'],
  ['kurum_vkno', 'Kurum VKN'],
  ['kurum_vd', 'Vergi dairesi'],
  ['kurum_telefon', 'Kurum telefonu'],
] as const;

export function BelgeYaziSekmesi() {
  const [kart, setKart] = useState<number | 'yeni' | null>(null);
  const [yenile, setYenile] = useState(0);

  return (
    <>
      <div className="kagrup">
        <div className="numaralama-bas">
          <h6>Belge Yazısı Şablonları</h6>
          <button className="d bir mini" onClick={() => setKart('yeni')}>＋ Yeni</button>
        </div>
        <GenGrid
          key={`belge-yazi-sablonu-${yenile}`}
          kaynak="belge-yazi-sablonu"
          gomulu
          seritGizli
          boyut={25}
          onSatirAc={satir => setKart(Number(satir.id))}
        />
      </div>

      <div className="not" style={{ marginTop: 8 }}>
        Gövde <b>düz metindir</b> — antet, başlık ve imza bloğu yazdırma
        ekranının sabit düzenidir, şablona yazılmaz. Aynı <b>tür · dil · şube</b>
         için yalnız <b>bir etkin</b> şablon olabilir; eski sürümü saklamak için
        durumunu <b>Pasif</b> yapın. Şube <b>0</b> tüm şubelerde geçerlidir,
        şubeye özel şablon onun önüne geçer.
      </div>

      <div className="kagrup">
        <h6>Yer Tutucular</h6>
        <div className="dk-havuz">
          {YER_TUTUCULAR.map(([k, aciklama]) => (
            <span key={k} className="dk-cip" title={aciklama}>{`{${k}}`}</span>
          ))}
        </div>
        <div className="not" style={{ marginTop: 6 }}>
          Değeri boş kalan yer tutucu <b>eksik</b> sayılır ve belge o haliyle
          hazırlanamaz. <b>{'{maas}'}</b> bordrodan gelmez — bordro modülü
          henüz yok; tutarı İK talebin <b>Maaş Tutarı</b> alanına girer.
        </div>
      </div>

      {kart && (
        <GenForm
          kaynak="belgeYaziSablonu"
          id={kart}
          baslik="Belge Yazısı Şablonu"
          onKapat={() => setKart(null)}
          onKaydedildi={() => { setKart(null); setYenile(t => t + 1) }}
        />
      )}
    </>
  );
}
