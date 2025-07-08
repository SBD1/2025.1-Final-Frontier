const express = require('express');
const {moveToSector, currSector, status, minerar, escanear, vender, saldo, upgrade} = require('../controllers/pilotControllers');
const authMiddleware = require('../middlewares/authMiddleware');

const router = express.Router();

// router.post('/register', authMiddleware, register);-
router.put('/move', authMiddleware, moveToSector);
router.get('/status', authMiddleware, status);
router.put('/minerar', authMiddleware, minerar);
router.get('/escanear', authMiddleware, escanear);
router.get('/vender', authMiddleware, vender);
router.get('/saldo', authMiddleware, saldo);
router.get('/upgrade', authMiddleware, upgrade);
// router.delete('/:id', authMiddleware, deletById);

module.exports = router;