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

exports.moveToSector = async (req, res) => {
    const {direction} = req.body;

    // check if direction is valid
    try {
        const pilot = await pool.query("SELECT * FROM pilot WHERE id = $1", [req.user.id]);
        const curr_sector = await pool.query("SELECT * FROM sector WHERE id = ($1)", [pilot.rows[0].sector_id]);

        if(direction == 'norte'){
            if(curr_sector.rows[0].nsector_id == null){
                return res.status(400).json({message: 'Não existe setores nessa direção.'});
            } else {
                const destiny_id = curr_sector.rows[0].nsector_id;
                await pool.query("UPDATE pilot SET sector_id = ($1)", [destiny_id]);
            } 
        } else if(direction == 'sul'){
            if(curr_sector.rows[0].ssector_id == null){
                return res.status(400).json({message: 'Não existe setores nessa direção.'});
            } else {
                const destiny_id = curr_sector.rows[0].ssector_id;
                await pool.query("UPDATE pilot SET sector_id = ($1)", [destiny_id]);
            }
        } else if(direction == 'oeste'){
            if(curr_sector.rows[0].wsector_id == null){
                return res.status(400).json({message: 'Não existe setores nessa direção.'});
            } else {
                const destiny_id = curr_sector.rows[0].wsector_id;
                await pool.query("UPDATE pilot SET sector_id = ($1)", [destiny_id]);
            } 
        } else if(direction == 'leste'){
            if(curr_sector.rows[0].esector_id == null){
                return res.status(400).json({message: 'Não existe setores nessa direção.'});
            } else {
                const destiny_id = curr_sector.rows[0].esector_id;
                await pool.query("UPDATE pilot SET sector_id = ($1)", [destiny_id]);
            } 
        } else {
            return res.status(400).json({message: 'Direção inválida!'});
        }

        const updt_pilot = await pool.query("SELECT * FROM pilot WHERE id = $1", [req.user.id]);        

        res.status(200).json(updt_pilot.rows[0]);
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