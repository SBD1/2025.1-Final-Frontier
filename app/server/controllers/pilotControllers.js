const pool = require('../config/db');

exports.currSector = async(req, res) => {
    try {
        result = await pool.query(
            "SELECT * FROM pilot WHERE id = $1",
            [req.user.id]
        );
        const sector_id = result.rows[0].sector_id;

        final_result = await pool.query(
            "SELECT * FROM sector WHERE id = $1",
            [sector_id]
        );
        
        res.status(201).json(final_result.rows[0]);
    } catch(err) {
        res.status(400).json({error: err.message});
    }
};

exports.status = async(req, res) => {
    const client = await pool.connect();
    const notices = []

    try {
        client.on('notice', (notice) => {
            notices.push(notice.message);
        });

        result = await client.query(
            "CALL status_piloto($1)",
            [req.user.id]
        );

        console.log(notices);
        res.status(201).json(notices);

    } catch(err) {
        res.status(400).json({error: err.message});
    }
}

exports.moveToSector = async (req, res) => {
    const {direction} = req.body;

    // check if direction is valid
    try {
        if (direction == 'norte'){
            await pool.query("CALL navegar_manual($1, '1');", [req.user.id]);
        } else if (direction == 'sul'){
            await pool.query("CALL navegar_manual($1, '2');", [req.user.id]);
        } else if (direction == 'leste'){
            await pool.query("CALL navegar_manual($1, '3');", [req.user.id]);
        } else if (direction == 'oeste'){
            await pool.query("CALL navegar_manual($1, '4');", [req.user.id]);
        }

        // res.status(200).json(response.rows[0]);
    } catch(err) {
        res.status(400).json({error: err.message});
    }

    // try {
    //     const result = await pool.query("UPDATE pilot SET sector_id = ($1) WHERE id = ($2)", [new_sector, req.user.id]);
    //     console.log(result.rows.length);
    //     res.status(200).json(result.rows);
    // } catch(err) {
    //     res.status(400).json({error: err.message});
    // }
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

// exports.deletById = async (req, res) => {
//     const { id } = req.params;

//     try {
//         const result = await pool.query("DELETE FROM galaxy WHERE id = $1 RETURNING *", [id]);

//         if (result.rowCount === 0) {
//             return res.status(404).json({message: 'Galáxia não encontrada'});
//         }

//         res.status(200).json({message: 'Galáxia deletada com sucesso!', deletedGalaxy: result.rows[0]});
//     } catch(err) {
//         res.status(500).json({message: 'Erro ao deletar a galáxia', error: err.message});
//     }
// };