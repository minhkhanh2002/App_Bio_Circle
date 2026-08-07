const https = require('https');
const fs = require('fs');
const path = require('path');

const targetPath = path.join(__dirname, 'builder.exe');

https.get('https://api.github.com/repos/MobAI-App/ios-builder/releases/latest', { headers: { 'User-Agent': 'node.js/app-bio-circle' } }, (res) => {
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
        try {
            const release = JSON.parse(data);
            const asset = release.assets.find(a => a.name.includes('windows'));
            if (asset) {
                console.log('Found Windows asset:', asset.name);
                console.log('Downloading from:', asset.browser_download_url);

                https.get(asset.browser_download_url, { headers: { 'User-Agent': 'node.js' } }, (downloadRes) => {
                    let location = asset.browser_download_url;
                    if (downloadRes.statusCode === 301 || downloadRes.statusCode === 302) {
                        location = downloadRes.headers.location;
                    }

                    https.get(location, { headers: { 'User-Agent': 'node.js' } }, (finalRes) => {
                        const file = fs.createWriteStream(targetPath);
                        finalRes.pipe(file);
                        file.on('finish', () => {
                            file.close();
                            console.log('Download complete. Saved to', targetPath);
                        });
                    }).on('error', (err) => console.error('Error downloading:', err.message));
                }).on('error', (err) => console.error('Error initiating download:', err.message));
            } else {
                console.log('No Windows asset found.');
            }
        } catch(e) {
            console.error('Error parsing JSON:', e);
        }
    });
}).on('error', (err) => {
    console.error('Error fetching release:', err.message);
});
