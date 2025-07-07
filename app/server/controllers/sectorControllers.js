const pool = require('../config/db');

exports.register = async(req, res) => {
    const { name } = req.body;

    try {
        await pool.query(
            "INSERT INTO sector (name) VALUES ($1) RETURNING *",
            [name]
        );
        res.status(201).json({message:'Setor cadastrado!'});
    } catch(err) {
        res.status(400).json({error: err.message});
    }
};

exports.connectSectors = async(req, res) => {
    const {origin, destiny, direction} = req.body;

    try {
        if (direction == 'n'){
            const isOriginAvailable = await pool.query("SELECT (nsector_id) FROM sector WHERE (name) = ($1)", [origin]);
            const isDestinyAvailable = await pool.query("SELECT (ssector_id) FROM sector WHERE (name) = ($1)", [destiny]);

            const origin_nsector = isOriginAvailable.rows[0].nsector_id;
            const destiny_ssector = isDestinyAvailable.rows[0].ssector_id;

            if(origin_nsector == null && destiny_ssector == null){
                const origin_result = await pool.query("SELECT (id) FROM sector WHERE (name) = ($1)", [origin]);
                const destiny_result = await pool.query("SELECT (id) FROM sector WHERE (name) = ($1)", [destiny]);

                const origin_id = origin_result.rows[0].id;
                const destiny_id = destiny_result.rows[0].id;

                await pool.query("UPDATE sector SET nsector_id = ($1) WHERE (id) = ($2)", [destiny_id, origin_id]);
                await pool.query("UPDATE sector SET ssector_id = ($1) WHERE (id) = ($2)", [origin_id, destiny_id]);

                const origin_newResult = await pool.query("SELECT (name, nsector_id) FROM sector WHERE (id) = ($1)", [origin_id]);

                res.status(201).json({message: 'Setores conectados!', origin: origin_newResult.rows[0].row});

            } else {
                res.json({message: 'Setores já possuem conexões nessa direção!', origin: isOriginAvailable.rows[0], destiny: isDestinyAvailable.rows[0]});

            }

        } else if (direction == 'w'){
            const isOriginAvailable = await pool.query("SELECT (wsector_id) FROM sector WHERE (name) = ($1)", [origin]);
            const isDestinyAvailable = await pool.query("SELECT (esector_id) FROM sector WHERE (name) = ($1)", [destiny]);

            const origin_wsector = isOriginAvailable.rows[0].wsector_id;
            const destiny_esector = isDestinyAvailable.rows[0].esector_id;

            if(origin_wsector == null && destiny_esector == null){
                const origin_result = await pool.query("SELECT (id) FROM sector WHERE (name) = ($1)", [origin]);
                const destiny_result = await pool.query("SELECT (id) FROM sector WHERE (name) = ($1)", [destiny]);

                const origin_id = origin_result.rows[0].id;
                const destiny_id = destiny_result.rows[0].id;

                await pool.query("UPDATE sector SET wsector_id = ($1) WHERE (id) = ($2)", [destiny_id, origin_id]);
                await pool.query("UPDATE sector SET esector_id = ($1) WHERE (id) = ($2)", [origin_id, destiny_id]);

                const origin_newResult = await pool.query("SELECT (name, wsector_id) FROM sector WHERE (id) = ($1)", [origin_id]);

                res.status(201).json({message: 'Setores conectados!', origin: origin_newResult.rows[0].row});

            } else {
                res.json({message: 'Setores já possuem conexões nessa direção!', origin: isOriginAvailable.rows[0], destiny: isDestinyAvailable.rows[0]});

            }

        } else if (direction == 's'){
            const isOriginAvailable = await pool.query("SELECT (ssector_id) FROM sector WHERE (name) = ($1)", [origin]);
            const isDestinyAvailable = await pool.query("SELECT (nsector_id) FROM sector WHERE (name) = ($1)", [destiny]);

            const origin_ssector = isOriginAvailable.rows[0].ssector_id;
            const destiny_nsector = isDestinyAvailable.rows[0].nsector_id;

            if(origin_ssector == null && destiny_nsector == null){
                const origin_result = await pool.query("SELECT (id) FROM sector WHERE (name) = ($1)", [origin]);
                const destiny_result = await pool.query("SELECT (id) FROM sector WHERE (name) = ($1)", [destiny]);

                const origin_id = origin_result.rows[0].id;
                const destiny_id = destiny_result.rows[0].id;

                await pool.query("UPDATE sector SET ssector_id = ($1) WHERE (id) = ($2)", [destiny_id, origin_id]);
                await pool.query("UPDATE sector SET nsector_id = ($1) WHERE (id) = ($2)", [origin_id, destiny_id]);

                const origin_newResult = await pool.query("SELECT (name, ssector_id) FROM sector WHERE (id) = ($1)", [origin_id]);

                res.status(201).json({message: 'Setores conectados!', origin: origin_newResult.rows[0].row});

            } else {
                res.json({message: 'Setores já possuem conexões nessa direção!', origin: isOriginAvailable.rows[0], destiny: isDestinyAvailable.rows[0]});

            }

        }  else if (direction == 'e'){
            const isOriginAvailable = await pool.query("SELECT (esector_id) FROM sector WHERE (name) = ($1)", [origin]);
            const isDestinyAvailable = await pool.query("SELECT (wsector_id) FROM sector WHERE (name) = ($1)", [destiny]);

            const origin_esector = isOriginAvailable.rows[0].esector_id;
            const destiny_wsector = isDestinyAvailable.rows[0].wsector_id;

            if(origin_esector == null && destiny_wsector == null){
                const origin_result = await pool.query("SELECT (id) FROM sector WHERE (name) = ($1)", [origin]);
                const destiny_result = await pool.query("SELECT (id) FROM sector WHERE (name) = ($1)", [destiny]);

                const origin_id = origin_result.rows[0].id;
                const destiny_id = destiny_result.rows[0].id;

                await pool.query("UPDATE sector SET esector_id = ($1) WHERE (id) = ($2)", [destiny_id, origin_id]);
                await pool.query("UPDATE sector SET wsector_id = ($1) WHERE (id) = ($2)", [origin_id, destiny_id]);

                const origin_newResult = await pool.query("SELECT (name, esector_id) FROM sector WHERE (id) = ($1)", [origin_id]);

                res.status(201).json({message: 'Setores conectados!', origin: origin_newResult.rows[0].row});

            } else {
                res.json({message: 'Setores já possuem conexões nessa direção ou direção incorreta.', origin: isOriginAvailable.rows[0], destiny: isDestinyAvailable.rows[0]});

            }

        }
    } catch(err) {
        res.status(400).json({error: err.message});

    }
};

exports.showMap = async(req, res) => {
    const client = await pool.connect();
    const notices = [];

    console.log('teste');

    try {
        client.on('notice', (notice) => {
            notices.push(notice.message);
        });

        result = await client.query(
            "CALL mostrar_mapa()"
        );

        console.log(notices);
        res.status(200).json(notices);

    } catch(err) {
        res.status(400).json({error: err.message});
    }
};

exports.getNearby = async (req, res) => {
    try {
        const result = await pool.query("SELECT (nsector_id, ssector_id, wsector_id, esector_id) FROM sector WHERE id = $1", [req.params.sector]);
        const resultString = result.rows[0].row.replace('(','').replace(')','').split(',');

        const nsector_name = await pool.query("SELECT name FROM sector WHERE id = $1", [Number(resultString[0])]);
        const ssector_name = await pool.query("SELECT name FROM sector WHERE id = $1", [Number(resultString[1])]);
        const wsector_name = await pool.query("SELECT name FROM sector WHERE id = $1", [Number(resultString[2])]);
        const esector_name = await pool.query("SELECT name FROM sector WHERE id = $1", [Number(resultString[3])]);
        
        let nsector = '';
        nsector_name.rows[0] ? nsector = nsector_name.rows[0].name : nsector = '';

        let ssector = '';
        ssector_name.rows[0] ? ssector = ssector_name.rows[0].name : ssector = '';

        let wsector = '';
        wsector_name.rows[0] ? wsector = wsector_name.rows[0].name : wsector = '';

        let esector = '';
        esector_name.rows[0] ? esector = esector_name.rows[0].name : esector = '';

        res.json({
            north: nsector,
            south: ssector,
            west: wsector,
            east: esector
        });
    } catch(err) {
        res.status(400).json({error: err.message});
    }
}

exports.putType = async (req, res) => {
    const { type } = req.body;

    try {
        const result = await pool.query("UPDATE sector SET type = $1 WHERE id = $2", [type, req.params.id]);
        res.status(200).json({ message: 'Tipo do setor atualizado com sucesso!', updatedSector: result.rows[0]});
    } catch(err) {
        res.status(500).json({ message: 'Erro ao alterar a galáxia', error: err.message });
    }
}

exports.deleteById = async (req, res) => {
    const { id } = req.params;

    try {
        const result = await pool.query("DELETE FROM sector WHERE id = $1 RETURNING *", [id]);

        if (result.rowCount === 0) {
            return res.status(404).json({message: 'Setor não encontrado'});
        }

        res.status(200).json({message: 'Setor deletado com sucesso!', deletedSector: result.rows[0]});
    } catch(err) {
        res.status(500).json({message: 'Erro ao deletar a galáxia', error: err.message});
    }
};