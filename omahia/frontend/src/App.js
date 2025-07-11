import React, { useState, useEffect } from 'react';
import logo from './logo.svg';
import './App.css';

function App() {
  const [backendStatus, setBackendStatus] = useState('');
  const [backendMessage, setBackendMessage] = useState('');

  useEffect(() => {
    // Ensure the backend is running on port 3001 as per our backend setup
    fetch('http://localhost:3001/api/health')
      .then(response => {
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
      })
      .then(data => {
        setBackendStatus(data.status || 'N/A');
        setBackendMessage(data.message || 'No message received');
      })
      .catch(error => {
        console.error("Error fetching backend health:", error);
        setBackendStatus('Error');
        setBackendMessage(error.message || 'Failed to fetch');
      });
  }, []);

  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Edit <code>src/App.js</code> and save to reload.
        </p>
        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          Learn React
        </a>
        <div>
          <h2>Backend Health Check:</h2>
          <p>Status: {backendStatus}</p>
          <p>Message: {backendMessage}</p>
        </div>
      </header>
    </div>
  );
}

export default App;
