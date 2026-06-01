# --- Этап 1: сборка статики ---
FROM node:22-alpine AS build

WORKDIR /app

# Сначала зависимости — для кэширования слоёв
COPY package*.json ./
RUN npm ci

# Остальные исходники (включая папку photos)
COPY . .
RUN npm run build

# --- Этап 2: раздача через nginx ---
FROM nginx:1.27-alpine AS production

# Конфиг для SPA (любой путь отдаёт index.html)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Собранная статика
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
