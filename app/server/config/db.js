const { Pool } = require('pg');

const pool = new Pool({
    user: 'postgres',
    host: 'localhost',
    database: 'finalf_db',
    password: '2626',
    port: 5432,
});

module.exports = pool;