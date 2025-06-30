import {BrowserRouter as Router, Routes, Route, Navigate} from 'react-router-dom';
import {useState} from 'react';
import Home from '../pages/Home';
import Game from '../pages/Game';
import PrivateRoute from '../components/PrivateRoute';
import { TerminalContextProvider } from 'react-terminal';

const AppRoutes = () => {
    const [isAuthenticated, setIsAuthenticated] = useState(() => {
        return localStorage.getItem('token') ? true : false;
    });

    return(
        <Router>
            <Routes>
                <Route path="/" element={<Home setIsAuthenticated={setIsAuthenticated} />} />
                <Route path="/game" element={isAuthenticated ? <PrivateRoute><Game /></PrivateRoute> : <Navigate to='/' />} />
            </Routes>
        </Router>


    );
};

export default AppRoutes;