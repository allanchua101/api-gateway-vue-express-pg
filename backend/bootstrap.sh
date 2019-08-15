#Scaffolding express project
express --view=pug

#Installing NPM dependencies
npm install

#Write Dockerfile
cat >Dockerfile <<EOL
FROM iron/node
WORKDIR /app
# Copy package.json + package-lock.json files
COPY package*.json ./
# Installing dependencies
RUN npm install
# Bundle app source 
COPY . .
EXPOSE 3000
ENTRYPOINT [ "npm", "start" ]
EOL

#Write .dockerignore
cat > .dockerignore <<EOL
node_modules
npm-debug.log
EOL