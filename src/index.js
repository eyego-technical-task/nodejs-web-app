const express = require('express');
const app = express();
const PORT = 3000;

// Root route
app.get('/', (req, res) => {
  res.send('Hello Eyego!');
});
HOST = '0.0.0.0'

app.listen(PORT, HOST, () => {
  console.log(`Server is running`);
});
