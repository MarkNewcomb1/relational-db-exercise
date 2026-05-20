const http    = require('http');
const fs      = require('fs');
const path    = require('path');
const { Pool } = require('pg');

const pool = new Pool({
    database: 'westfield',
    user:     'westfield_readonly',
    password: 'readonly_pass',
    host:     'localhost',
    port:     5432,
});

const BLOCKED = /\b(ALTER|DROP|CREATE|INSERT|UPDATE|DELETE|TRUNCATE)\b/i;

const server = http.createServer(async (req, res) => {
    if (req.method === 'GET' && req.url === '/') {
        const html = fs.readFileSync(path.join(__dirname, 'index.html'));
        res.writeHead(200, { 'Content-Type': 'text/html' });
        return res.end(html);
    }

    if (req.method === 'POST' && req.url === '/query') {
        let body = '';
        req.on('data', chunk => { body += chunk; });
        req.on('end', async () => {
            let sql;
            try { sql = JSON.parse(body).sql; } catch {
                res.writeHead(400, { 'Content-Type': 'application/json' });
                return res.end(JSON.stringify({ error: 'Invalid request body.' }));
            }

            if (!sql || !sql.trim()) {
                res.writeHead(400, { 'Content-Type': 'application/json' });
                return res.end(JSON.stringify({ error: 'Empty query.' }));
            }

            if (BLOCKED.test(sql)) {
                res.writeHead(403, { 'Content-Type': 'application/json' });
                return res.end(JSON.stringify({ error: 'Write operations are not permitted.' }));
            }

            try {
                const result = await pool.query(sql);
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ rows: result.rows, fields: result.fields.map(f => f.name) }));
            } catch (err) {
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ error: err.message }));
            }
        });
        return;
    }

    res.writeHead(404);
    res.end('Not found');
});

const PORT = 3000;
server.listen(PORT, () => console.log(`Westfield frontend running at http://localhost:${PORT}`));
