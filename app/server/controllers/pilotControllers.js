const pool = require('../config/db');

exports.status = async(req, res) => {
    const client = await pool.connect();
    const notices = [];

    try {
        client.on('notice', (notice) => {
            notices.push(notice.message);
        });

        result = await client.query(
            "CALL status_piloto($1)",
            [req.user.id]
        );

        res.status(201).json(notices);

    } catch(err) {
        res.status(400).json({error: err.message});
    }
};

exports.moveToSector = async (req, res) => {
    const {direction} = req.body;
    const client = await pool.connect();
    const notices = [];

    try {

        client.on('notice', (notice) => {
            notices.push(notice.message);
        });

        if (direction == 'norte'){
            await client.query("CALL navegar_manual($1, '1');", [req.user.id]);
        } else if (direction == 'sul'){
            await client.query("CALL navegar_manual($1, '2');", [req.user.id]);
        } else if (direction == 'leste'){
            await client.query("CALL navegar_manual($1, '3');", [req.user.id]);
        } else if (direction == 'oeste'){
            await client.query("CALL navegar_manual($1, '4');", [req.user.id]);
        }

        res.status(201).json(notices);
    } catch(err) {
        res.status(400).json({error: err.message});
    }
};

exports.minerar = async (req, res) => {
    const {minerio} = req.params.nomeMinerio
    try {
        if (minerio == 'Prismatina'){
            await pool.query("CALL coletar_minerio($1, '1');", [req.user.id]);
        } else if (minerio == 'Zetânio'){
            await pool.query("CALL coletar_minerio($1, '2');", [req.user.id]);
        } else if (minerio == 'Cronóbio'){
            await pool.query("CALL coletar_minerio($1, '3');", [req.user.id]);
        }
    } catch(err) {
        res.status(400).json({error: err.message});
    }
}