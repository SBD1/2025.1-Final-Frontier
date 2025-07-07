require('dotenv').config();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../config/db');

exports.register = async(req, res) => {
    const { username, password } = req.body;

    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        await pool.query(
            "INSERT INTO piloto (email, senha) VALUES ($1, $2) RETURNING *",
            [username, hashedPassword]
        );
        res.status(201).json({message:'Usuário cadastrado!'});
    } catch(err) {
        res.status(400).json({error:err.message});
    }
};

exports.login = async(req, res) => {
    const { username, password } = req.body;

    try {
        const user = await pool.query("SELECT * FROM piloto WHERE email = $1", [username]);
        if (user.rows.length === 0) return res.status(400).json({error: 'Usuário não encontrado!'});

        const validPassword = await bcrypt.compare(password, user.rows[0].senha);
        if (!validPassword) return res.status(400).json({error: 'Senha inválida!'});

        const token = jwt.sign(
            {id:user.rows[0].id, username}, 
            process.env.JWT_SECRET,
            {expiresIn: '1h'}
        );
        res.json({token});
    } catch(err) {
        res.status(500).json({error: err.message});
    }
};

exports.profile = async(req, res) => {
    try {
        const user = await pool.query("SELECT id, username FROM pilot WHERE id = $1", [req.user.id]);
        res.status(200).json(user.rows[0]);
    } catch(err) {
        res.status(500).json({error:err.message});
    }
};
