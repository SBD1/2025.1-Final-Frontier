const express = require('express');
const {register, getAll, connectSectors, deleteById, getNearby, putType} = require('../controllers/sectorControllers');
const authMiddleware = require('../middlewares/authMiddleware');

const router = express.Router();

router.post('/register', authMiddleware, register);
router.get('/all', authMiddleware, getAll);
router.put('/connect', authMiddleware, connectSectors);
router.put('/type/:id', authMiddleware, putType);
router.get('/nearby/:sector', authMiddleware, getNearby);
router.delete('/:id', authMiddleware, deleteById);

module.exports = router;