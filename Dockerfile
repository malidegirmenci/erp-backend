# Stage 1: Build the application
FROM node:18-alpine AS builder
WORKDIR /usr/src/app

COPY package*.json ./

# Build için gerekli olan devDependencies dahil tüm bağımlılıkları yükle
RUN npm ci

# Kaynak kodunun geri kalanını kopyala
COPY . .

# Uygulamayı build et (Bu aşamada @nestjs/cli gibi devDependencies'e erişim olacak)
RUN npm run build

# Build bittikten sonra, üretim için gereksiz olan devDependencies'i node_modules'tan kaldır
RUN npm prune --production

# Stage 2: Setup production environment
FROM node:18-alpine
WORKDIR /usr/src/app

# Sadece üretim için gerekli olan node_modules'ı ve build edilmiş uygulamayı kopyala
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/dist ./dist

# Ortam değişkenlerinden portu alacak, varsayılan 3000
EXPOSE ${PORT:-3000}

# Uygulamayı başlat
CMD ["node", "dist/main.js"]