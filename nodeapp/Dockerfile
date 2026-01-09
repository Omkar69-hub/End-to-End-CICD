FROM node:14           # Use Node.js version 14  as the base image
WORKDIR /usr/app       # Set the working directory inside the container
COPY package*.json .   # Copy package.json and package-lock.json to the working directory
RUN npm install        # Install the dependencies listed in package.json        
COPY . .               # Copy the rest of the application code to the working directory     
EXPOSE 8080            # Expose port 8080 for the application       
CMD ["node", "app.js"]  # Command to run the application        