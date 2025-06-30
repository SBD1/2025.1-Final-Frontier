const express = require('express');
const {moveToSector, currSector} = require('../controllers/pilotControllers');
const authMiddleware = require('../middlewares/authMiddleware');

const router = express.Router();

// router.post('/register', authMiddleware, register);
router.get('/currSector', authMiddleware, currSector);
router.put('/move', authMiddleware, moveToSector);
// router.delete('/:id', authMiddleware, deletById);

module.exports = router;