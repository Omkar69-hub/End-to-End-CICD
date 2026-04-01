# Use latest stable Node.js
FROM node:24

# Set working directory
WORKDIR /usr/app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy app code
COPY . .

# Expose correct port
EXPOSE 3000

# Run app
CMD ["node", "app.js"]