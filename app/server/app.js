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