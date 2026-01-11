# Use Node.js version 14  as the base image
FROM node:14 

# Set the working directory inside the container
WORKDIR /usr/app 

# Copy package.json and package-lock.json to the working directory
COPY package*.json . 

# Install the dependencies listed in package.json  
RUN npm install  

# Copy the rest of the application code to the working directory              
COPY . .      

# Expose port 8080 for the application             
EXPOSE 8080     

# Command to run the application               
CMD ["node", "app.js"] 
       