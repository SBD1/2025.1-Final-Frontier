const pool = require('../config/db');

exports.register = async(req, res) => {
    const { name } = req.body;

    try {
        await pool.query(
            "INSERT INTO galaxy (name) VALUES ($1) RETURNING *",
            [name]
        );
        res.status(201).json({message:'Galáxia cadastrada!'});
    } catch(err) {
        res.status(400).json({error: err.message});
    }
};

exports.getAll = async (req, res) => {
    try {
        const result = await pool.query("SELECT * FROM galaxy");
        console.log(result.rows.length);
        res.status(200).json(result.rows);
    } catch(err) {
        res.status(400).json({error: err.message});
    }
};

exports.deletById = async (req, res) => {
    const { id } = req.params;

    try {
        const result = await pool.query("DELETE FROM galaxy WHERE id = $1 RETURNING *", [id]);

        if (result.rowCount === 0) {
            return res.status(404).json({message: 'Galáxia não encontrada'});
        }

        res.status(200).json({message: 'Galáxia deletada com sucesso!', deletedGalaxy: result.rows[0]});
    } catch(err) {
        res.status(500).json({message: 'Erro ao deletar a galáxia', error: err.message});
    }
};