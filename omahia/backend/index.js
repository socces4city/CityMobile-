const express = require('express');
const cors = require('cors'); // Import cors
const app = express();
const port = process.env.PORT || 3001;

// Enable CORS for all routes and origins
// For development, this is fine. For production, you'll want to restrict origins.
app.use(cors());

app.get('/api/health', (req, res) => {
  res.json({ status: 'UP', message: 'Backend is healthy' });
});

app.listen(port, () => {
  console.log(`Backend server listening at http://localhost:${port}`);
});
