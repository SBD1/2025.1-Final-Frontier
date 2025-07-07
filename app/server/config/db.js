const { Pool } = require('pg');

const pool = new Pool({
    user: 'postgres',
    host: 'localhost',
    database: 'finalfrontierdb',
    password: '2626',
    port: 5432,
});

pool.on('notice', (notice) => {
    console.log('PG NOTICE:', notice.message);
});

module.exports = pool;