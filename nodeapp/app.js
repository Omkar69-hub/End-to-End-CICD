const express = require('express');
const app = express();
const port = 8080;

app.get('/', (req, res) => {
  res.send('Service is up and running');
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
