const express = require('express');
const {register, getAll, deletById} = require('../controllers/galaxyControllers');
const authMiddleware = require('../middlewares/authMiddleware');

const router = express.Router();

router.post('/register', authMiddleware, register);
router.get('/all', authMiddleware, getAll);
router.delete('/:id', authMiddleware, deletById);

module.exports = router;