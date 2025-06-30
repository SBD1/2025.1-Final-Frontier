require('dotenv').config();
const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/authRoutes');
const galaxyRoutes = require('./routes/galaxyRoutes');
const sectorRoutes = require('./routes/sectorRoutes');
const pilotRoutes = require('./routes/pilotRoutes');

const app = express();
app.use(function(req,res,next) {
    res.header("Access-Control-Allow-Origin", "http://localhost:3000");
    res.header("Acess-Control-Allow-Headers", "Origin, X-Requested-With", "Content-Type, Accpet");
    next();
})
app.use(express.json());
app.use(cors({
    origin: 'http://localhost:3000',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true
}));

app.use('/api/auth', authRoutes);
app.use('/api/galaxy', galaxyRoutes);
app.use('/api/sector', sectorRoutes);
app.use('/api/pilot', pilotRoutes);

module.exports = app;

// app.get('/profile', authenticateToken, async(req, res) => {
//     try {
//         const user = await pool.query("SELECT id, username FROM pilot WHERE id = $1", req.user.id);
//         res.json(user.rows[0]);
//     } catch(err) {
//         res.status(500).json({error:err.message});
//     }
// });

// function authenticateToken(req, res, next) {
//     const token = req.header('Authorization')?.split(' ')[1];
//     if (!token) return res.status(401).json({error:'Acesso negado!'});

//     jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
//         if (err) return res.status(403).json({error: 'Token inválido!'});
//         req.user = user;
//         next();
//     });
// }

// app.listen(5000, () => console.log('Server running on port 5000!'));

// async function connectionTest() {
//     try {
//         const res = await pool.query('SELECT NOW()');
//         console.log('Successful conncetion! Time: ', res.rows[0].now);
//     } catch(err) {
//         console.error('Error: ', err);
//     }
// }