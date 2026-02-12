const express = require('express');
const fs = require('fs');
const app = express();
const PORT = process.env.PORT || 8080;

// This path will be mounted to our shared EFS volume
const DATA_FILE = '/mnt/efs/visits.txt';

app.get('/', (req, res) => {
    let count = 0;
    try {
        if (fs.existsSync(DATA_FILE)) {
            count = parseInt(fs.readFileSync(DATA_FILE, 'utf8')) || 0;
        }
        count++;
        fs.writeFileSync(DATA_FILE, count.toString());
    } catch (err) {
        console.error("Error writing to EFS:", err);
        return res.send("Error: Could not write to shared volume.");
    }

    // app/index.js
res.send(`
    <body style="background-color: #5cec5c; font-family: sans-serif;">
       <h1>new version</h1>
        <h1>🚀 Hello from the AUTOMATED Version!</h1>
        <p>This was deployed via GitHub Actions.</p>
        <p>Total shared visits: <b>${count}</b></p>
    </body>
`);
});

app.listen(PORT, () => console.log(`App running on port ${PORT}`));