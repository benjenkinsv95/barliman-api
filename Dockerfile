FROM node:8

# From: https://github.com/msgodf/docker-petite-chez-scheme/blob/master/Dockerfile
RUN yum install -y wget
RUN wget http://www.scheme.com/download/PetiteChezScheme-8.4-1.i386.rpm
RUN yum install -y --nogpgcheck PetiteChezScheme-8.4-1.i386.rpm
RUN rm PetiteChezScheme-8.4-1.i386.rpm

# Create app directory
WORKDIR /app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./

RUN npm install
# If you are building your code for production
# RUN npm install --only=production

# Bundle app source
COPY . .

EXPOSE 80
CMD [ "npm", "start" ]