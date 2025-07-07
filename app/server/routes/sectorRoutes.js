const express = require('express');
const {register, connectSectors, deleteById, getNearby, putType, showMap} = require('../controllers/sectorControllers');
const authMiddleware = require('../middlewares/authMiddleware');

const router = express.Router();

router.post('/register', authMiddleware, register);
router.put('/connect', authMiddleware, connectSectors);
router.get('/showMap', authMiddleware, showMap);
router.put('/type/:id', authMiddleware, putType);
router.get('/nearby/:sector', authMiddleware, getNearby);
router.delete('/:id', authMiddleware, deleteById);

module.exports = router;