/**
 * EKSTRE İKONU (kullanıcı 25.10.2026: "ekstre ikonu sigma yap" → "daha gösterişli sigma yok mu"): emoji setinde
 * sigma yok, düz "Σ" karakteri ikon gibi durmuyor - mavi yuvarlak kare üstünde beyaz kalın Σ çizilir. Menüde
 * `@ekstre` (MenuIkon) ve ekstreyi açan düğmelerde aynı çizim. Bağımsız dosya: menü ve sayfalar import döngüsüne
 * girmeden kullansın.
 */
export function EkstreIkon({ boyut = 16 }: { boyut?: number }) {
  return (
    <svg viewBox="0 0 24 24" width={boyut} height={boyut} aria-hidden="true"
         style={{ verticalAlign: '-3px', flex: 'none' }}>
      {/* DÜZ RENK zemin: gradyan url(#id) ile verilince aynı id'nin ilk tanımı gizli menüde kalınca zemin hiç
          boyanmıyordu (başlıkta soluk, sekmede boş). */}
      <rect x="0.5" y="0.5" width="23" height="23" rx="5" fill="#2463b0" />
      {/* Kalın ÇİZGİ Σ (dolgu şekli 16 px'te seçilmiyordu - kullanıcı: "sigma belli olmuyor"). */}
      <polyline points="17.5,5.5 6.5,5.5 13,12 6.5,18.5 17.5,18.5" fill="none" stroke="#fff"
                strokeWidth="3" strokeLinejoin="miter" strokeLinecap="square" />
    </svg>
  );
}
