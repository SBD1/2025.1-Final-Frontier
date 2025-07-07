import axios from 'axios';

const API_BASE_URL = 'http://localhost:5000/api';

const api = axios.create({
    baseURL: API_BASE_URL,
    headers: {
        'Content-Type': 'application/json',
    },
});

export const login = async (credentials) => {
    try {
        const response = await api.post('/auth/login', credentials);
        return response.data;
    } catch (err) {
        throw err;
    }
};

export const showGameMap = async () => {
    const token = localStorage.getItem('token');
    try {
        const response = await api.get('/sector/showMap', {
            headers: {
                Authorization: `Bearer ${token}`,
            }
        });
        console.log(response.data);
        return response.data;
    } catch (err) {
        console.error('Erro ao recuperar status: ', err);
        throw err;
    }
};

export const register = async (credentials) => {
    try {
        const response = await api.post('/auth/register', credentials);
        return response.data;
    } catch (err) {
        console.error('Erro de login: ', err);
        throw err;
    }
};

export const currSector = async () => {
    const token = localStorage.getItem('token');
    try {
        const response = await api.get('/pilot/currSector', {
            headers: {
                Authorization: `Bearer ${token}`,
            }
        });
        return response.data;
    } catch (err) {
        console.error('Erro ao identificar setor: ', err);
        throw err;
    }
};

export const pilotStatus = async () => {
    const token = localStorage.getItem('token');
    try {
        const response = await api.get('/pilot/status', {
            headers: {
                Authorization: `Bearer ${token}`,
            }
        });
        console.log(response.data);
        return response.data;
    } catch (err) {
        console.error('Erro ao recuperar status: ', err);
        throw err;
    }
};

export const moveToSector = async (direction) => {
    const token = localStorage.getItem('token');
    console.log(direction);
    try {
        const response = await api.put('/pilot/move', (direction), {
            headers: {
                Authorization: `Bearer ${token}`,
            }
        });
        return response.data;
    } catch (err) {
        console.error('Erro ao identificar setor: ', err);
        throw err;
    }
};

export const findNearbySectors = async (id) => {
    const token = localStorage.getItem('token');

    try {
        const response = await api.get(`/sector/nearby/${id}`, {
            headers: {
                Authorization: `Bearer ${token}`,
            }
        });
        // console.log(response.data.north);
        return response.data;
    } catch(err) {
        console.error('Erro ao coletar setores: ', err);
        throw err;
    }
}

export default api;