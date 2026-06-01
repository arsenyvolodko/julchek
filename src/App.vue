<script setup>
import { ref, computed } from 'vue'

// Подтягиваем все фото из папки photos. Подпись = имя файла (без .jpg).
const modules = import.meta.glob('../photos/*.jpg', {
  eager: true,
  query: '?url',
  import: 'default',
})

const allPhotos = Object.entries(modules).map(([path, url]) => {
  const name = path.split('/').pop().replace(/\.jpg$/i, '')
  return { name, url }
})

// Центральная большая фотография — "любимая и единственная"
const favorite = allPhotos.find((p) => p.name === 'самая любимая')

// Ключ сортировки: если название начинается со слова "самая"/"самый"/"самые",
// отбрасываем его и сортируем по следующему слову.
function sortKey(name) {
  return name.replace(/^сам(ая|ый|ые|ыми|ое)\s+/i, '')
}

const photos = allPhotos
  .filter((p) => p.name !== 'самая любимая')
  .sort((a, b) => sortKey(a.name).localeCompare(sortKey(b.name), 'ru'))

// Набор открытых фото. Клик переключает конкретное фото и не трогает остальные.
const revealed = ref(new Set())
function reveal(name) {
  const next = new Set(revealed.value)
  if (next.has(name)) {
    next.delete(name)
  } else {
    next.add(name)
  }
  revealed.value = next
}

const favoriteRevealed = ref(false)

// Воздушные шарики и конфетти для праздничной анимации
const balloons = computed(() =>
  Array.from({ length: 12 }, (_, i) => ({
    id: i,
    left: 4 + i * 8 + (i % 3) * 2,
    delay: (i % 6) * 0.9,
    duration: 9 + (i % 5) * 1.6,
    color: ['#ffb44d', '#ff8f3f', '#ffd06b', '#f4a259', '#ffc97a'][i % 5],
  })),
)

const confetti = computed(() =>
  Array.from({ length: 60 }, (_, i) => ({
    id: i,
    left: (i * 37) % 100,
    delay: (i % 12) * 0.4,
    duration: 4 + (i % 7),
    color: ['#ffb44d', '#ff8f3f', '#ffd06b', '#f4a259', '#ffe0a3', '#e98a3c'][i % 6],
    size: 6 + (i % 4) * 3,
  })),
)
</script>

<template>
  <!-- ЭКРАН 1: Поздравление -->
  <section class="hero">
    <div class="confetti-layer">
      <span
        v-for="c in confetti"
        :key="'c' + c.id"
        class="confetti"
        :style="{
          left: c.left + '%',
          animationDelay: c.delay + 's',
          animationDuration: c.duration + 's',
          background: c.color,
          width: c.size + 'px',
          height: c.size * 1.6 + 'px',
        }"
      />
    </div>

    <div class="balloons-layer">
      <span
        v-for="b in balloons"
        :key="'b' + b.id"
        class="balloon"
        :style="{
          left: b.left + '%',
          animationDelay: b.delay + 's',
          animationDuration: b.duration + 's',
          '--balloon-color': b.color,
        }"
      />
    </div>

    <div class="hero-content">
      <p class="hero-kicker">✨ Сегодня твой день ✨</p>
      <h1 class="hero-title">
        <span class="line">Юлечка,</span>
        <span class="line big">с Днём Рождения!</span>
      </h1>
      <p class="hero-sub">🎂 🎈 🎁 🌷</p>
      <a class="scroll-btn" href="#about">какая ты (или какой я тебя вижу) ↓</a>
    </div>
  </section>

  <!-- ЭКРАН 2: Какая ты -->
  <section id="about" class="about">
    <h2 class="about-title">Какая ты</h2>
    <p class="about-hint">нажми на каждое окошко 💛</p>

    <div class="grid">
      <figure
        v-for="photo in photos"
        :key="photo.name"
        class="card"
        :class="{ revealed: revealed.has(photo.name) }"
        @click="reveal(photo.name)"
      >
        <div class="img-wrap">
          <img :src="photo.url" :alt="photo.name" loading="lazy" />
        </div>
        <figcaption>{{ photo.name }}</figcaption>
      </figure>
    </div>

    <!-- Центральная большая фотография -->
    <div v-if="favorite" class="favorite-block">
      <p class="favorite-lead">а самое главное — ты…</p>
      <figure
        class="favorite-card"
        :class="{ revealed: favoriteRevealed }"
        @click="favoriteRevealed = !favoriteRevealed"
      >
        <div class="img-wrap">
          <img :src="favorite.url" :alt="favorite.name" />
        </div>
        <figcaption>{{ favorite.name }}</figcaption>
      </figure>
      <p class="favorite-foot">с любовью от Сени 💛</p>
    </div>
  </section>
</template>

<style scoped>
/* ===================== ЭКРАН 1 ===================== */
.hero {
  position: relative;
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  text-align: center;
  overflow: hidden;
  background:
    radial-gradient(circle at 20% 20%, #ffe7b3 0%, transparent 55%),
    radial-gradient(circle at 80% 30%, #ffd28a 0%, transparent 50%),
    linear-gradient(160deg, #fff3d6 0%, #ffd9a0 45%, #ffba6b 100%);
}

.hero-content {
  position: relative;
  z-index: 3;
  padding: 2rem;
}

.hero-kicker {
  font-size: 1.2rem;
  letter-spacing: 0.3em;
  text-transform: uppercase;
  color: #c9722b;
  margin-bottom: 1.2rem;
  animation: fade-in 1.2s ease both;
}

.hero-title {
  font-weight: 700;
  line-height: 1.05;
  text-shadow: 0 4px 18px rgba(201, 114, 43, 0.25);
}

.hero-title .line {
  display: block;
  animation: pop-in 0.9s cubic-bezier(0.18, 0.89, 0.32, 1.28) both;
}

.hero-title .line:first-child {
  font-size: clamp(2.4rem, 7vw, 5rem);
  color: #b85c1e;
}

.hero-title .big {
  font-size: clamp(3rem, 11vw, 8rem);
  color: #e9822f;
  animation-delay: 0.25s;
}

.hero-sub {
  font-size: clamp(1.6rem, 4vw, 2.6rem);
  margin-top: 1.4rem;
  animation: fade-in 1.4s ease 0.6s both;
}

.scroll-btn {
  display: inline-block;
  margin-top: 2.6rem;
  padding: 0.85rem 2.4rem;
  font-size: 1.15rem;
  color: #fff;
  background: linear-gradient(135deg, #ff9f43, #e9822f);
  border-radius: 999px;
  text-decoration: none;
  box-shadow: 0 10px 24px rgba(233, 130, 47, 0.4);
  transition: transform 0.25s, box-shadow 0.25s;
  animation: fade-in 1.6s ease 0.9s both, bob 2.4s ease-in-out 1.6s infinite;
}

.scroll-btn:hover {
  transform: translateY(-3px) scale(1.04);
  box-shadow: 0 14px 30px rgba(233, 130, 47, 0.5);
}

/* Конфетти */
.confetti-layer,
.balloons-layer {
  position: absolute;
  inset: 0;
  z-index: 1;
  pointer-events: none;
}

.confetti {
  position: absolute;
  top: -40px;
  border-radius: 2px;
  opacity: 0.85;
  animation-name: fall;
  animation-timing-function: linear;
  animation-iteration-count: infinite;
}

@keyframes fall {
  0% {
    transform: translateY(-40px) rotate(0deg);
    opacity: 0;
  }
  10% {
    opacity: 0.9;
  }
  100% {
    transform: translateY(105vh) rotate(720deg);
    opacity: 0.9;
  }
}

/* Шарики */
.balloon {
  position: absolute;
  bottom: -160px;
  width: 46px;
  height: 58px;
  background: var(--balloon-color);
  border-radius: 50% 50% 50% 50% / 55% 55% 45% 45%;
  box-shadow: inset -6px -8px 12px rgba(0, 0, 0, 0.12);
  animation-name: rise;
  animation-timing-function: ease-in;
  animation-iteration-count: infinite;
}

.balloon::after {
  content: '';
  position: absolute;
  top: 100%;
  left: 50%;
  width: 1px;
  height: 70px;
  background: rgba(150, 90, 30, 0.4);
}

@keyframes rise {
  0% {
    transform: translateY(0) rotate(-4deg);
    opacity: 0;
  }
  15% {
    opacity: 0.9;
  }
  100% {
    transform: translateY(-120vh) rotate(4deg);
    opacity: 0;
  }
}

/* ===================== ЭКРАН 2 ===================== */
.about {
  padding: 5rem 1.5rem 6rem;
  max-width: 1200px;
  margin: 0 auto;
  text-align: center;
}

.about-title {
  font-size: clamp(2.4rem, 7vw, 4.5rem);
  color: #d2742a;
  margin-bottom: 0.4rem;
}

.about-hint {
  font-size: 1.1rem;
  color: #a9824f;
  margin-bottom: 3rem;
}

.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 1.6rem;
}

.card {
  cursor: pointer;
  background: #fffdf7;
  border-radius: 18px;
  padding: 0.7rem;
  box-shadow: 0 8px 22px rgba(180, 120, 50, 0.16);
  transition: transform 0.3s, box-shadow 0.3s;
}

.card:hover {
  transform: translateY(-4px);
  box-shadow: 0 14px 30px rgba(180, 120, 50, 0.26);
}

.img-wrap {
  position: relative;
  overflow: hidden;
  border-radius: 12px;
  aspect-ratio: 3 / 4;
}

.img-wrap img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
  filter: blur(16px) brightness(1.05);
  transform: scale(1.08);
  transition: filter 0.7s ease, transform 0.7s ease;
}

.card.revealed .img-wrap img {
  filter: blur(0);
  transform: scale(1);
}

.img-wrap::after {
  content: '🔍 нажми';
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.95rem;
  color: #fff;
  text-shadow: 0 2px 8px rgba(0, 0, 0, 0.4);
  background: rgba(233, 130, 47, 0.15);
  opacity: 1;
  transition: opacity 0.5s;
  pointer-events: none;
}

.card.revealed .img-wrap::after,
.favorite-card.revealed .img-wrap::after {
  opacity: 0;
}

figcaption {
  margin-top: 0.7rem;
  font-size: 1.2rem;
  color: #b85c1e;
  font-style: italic;
}

/* Центральная фотография */
.favorite-block {
  margin-top: 5.5rem;
}

.favorite-lead {
  font-size: clamp(1.4rem, 4vw, 2.2rem);
  color: #c9722b;
  margin-bottom: 1.6rem;
}

.favorite-card {
  cursor: pointer;
  display: inline-block;
  max-width: 520px;
  width: 100%;
  background: #fffdf7;
  padding: 1rem;
  border-radius: 24px;
  box-shadow: 0 16px 44px rgba(180, 120, 50, 0.3);
  transition: transform 0.4s;
}

.favorite-card:hover {
  transform: scale(1.02);
}

.favorite-card .img-wrap {
  aspect-ratio: 4 / 5;
}

.favorite-card .img-wrap img {
  filter: blur(22px) brightness(1.05);
}

.favorite-card.revealed .img-wrap img {
  filter: blur(0);
  transform: scale(1);
}

.favorite-card figcaption {
  font-size: clamp(1.6rem, 4vw, 2.4rem);
  font-weight: 700;
  font-style: normal;
  color: #e9822f;
  margin-top: 1rem;
}

.favorite-foot {
  margin-top: 1.6rem;
  font-size: 1.4rem;
  color: #c9722b;
}

/* ===================== Анимации ===================== */
@keyframes fade-in {
  from {
    opacity: 0;
    transform: translateY(14px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes pop-in {
  0% {
    opacity: 0;
    transform: scale(0.6) translateY(30px);
  }
  100% {
    opacity: 1;
    transform: scale(1) translateY(0);
  }
}

@keyframes bob {
  0%,
  100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-6px);
  }
}

@media (prefers-reduced-motion: reduce) {
  .confetti,
  .balloon,
  .scroll-btn {
    animation: none;
  }
}
</style>
