# Stage 1: Build the application
FROM node:18-alpine AS builder
WORKDIR /usr/src/app

# Bağımlılıkları yükle (sadece production)
COPY package*.json ./
RUN npm ci --only=production

# Kaynak kodunu kopyala ve uygulamayı build et
COPY . .
RUN npm run build

# Stage 2: Setup production environment
FROM node:18-alpine
WORKDIR /usr/src/app

# Build edilmiş uygulamayı ve node_modules'ı kopyala
COPY --from=builder /usr/src/app/dist ./dist
COPY --from=builder /usr/src/app/node_modules ./node_modules

# Ortam değişkenlerinden portu alacak, varsayılan 3000
EXPOSE ${PORT:-3000}

# Uygulamayı başlat
CMD ["node", "dist/main.js"]