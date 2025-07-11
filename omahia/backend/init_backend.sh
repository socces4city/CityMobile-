#!/bin/bash
cd /app/omahia/backend || exit 1 # Exit if cd fails

echo "Current directory: $(pwd)"
echo "Initializing npm project..."
npm init -y
echo "Installing express..."
npm install express
echo "Creating basic index.js..."
cat <<EOL > index.js
const express = require('express');
const app = express();
const port = process.env.PORT || 3001;

app.get('/api/health', (req, res) => {
  res.json({ status: 'UP', message: 'Backend is healthy' });
});

app.listen(port, () => {
  console.log(\`Backend server listening at http://localhost:\${port}\`);
});
EOL
echo "Backend initialization script finished."
