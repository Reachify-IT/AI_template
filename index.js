const express = require('express');
const axios = require('axios');

const app = express();
const PORT = 3000;

// Middleware
app.use(express.json());

// Route to call an external server
app.get('/call-server', async (req, res) => {
    try {
        const response = await axios.get('https://localhost:8000/api'); // Replace with actual server URL
        res.json(response.data);
    } catch (error) {
        res.status(500).json({ message: 'Error calling the server', error: error.message });
    }
});

// Start the server
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
