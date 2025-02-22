FROM node:16  # Or another suitable Node.js version

WORKDIR /usr/src/app

COPY package*.json ./

# Install app dependencies
RUN npm install

COPY . .

# Expose the port the app runs on
EXPOSE 3000

# Define the command to run your app
CMD [ "npm", "start" ]