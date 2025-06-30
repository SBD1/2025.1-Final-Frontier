import './style.css';
import { useNavigate } from 'react-router-dom';
import { useAsciiText, subZero } from 'react-ascii-text';
import { login, register } from '../connection/api';
import { useState } from 'react';

function Home({ setIsAuthenticated }) {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [output, setOutput] = useState('');

    const navigate = useNavigate();
    const asciiTextRef = useAsciiText({
        font: subZero,
        text: 'final frontier',
        animationLoop: false,
        animationSpeed: 100,
        animationDelay: 500,
        animationDirection: 'down',
        fadeInOnly: true,
    });

    const handleUsernameChange = (e) => {
        setUsername(e.target.value);
    };

    const handlePasswordChange = (e) => {
        setPassword(e.target.value);
    };

    const handleLogin = async(e) => {
        e.preventDefault();

        try {
            const response = await login({ username, password });
            localStorage.setItem('token', response.token);
            setIsAuthenticated(true);
            navigate('/game');
        } catch (err) {
            setOutput(err.response.data.error);
        }

    };

    const handleRegister = async(e) => {
        e.preventDefault();

        try {
            const response = await register({ username, password });
            setOutput(response.data);
        } catch (err) {
            setOutput(err.response.data.error);
        }

    };

    return(
        <div className='container'>
            <div className='centerTitle'>
                <div className='homeRow'>
                    <p className='mainText'>WELCOME PILOT TO THE</p>
                </div>
            </div>
            <div className='homeRow'>
                <pre ref={asciiTextRef} className='mainTitle'></pre>
            </div>
            <div className='homeRow'>
                <form className='loginForm' onSubmit={handleLogin}>
                    <div className={'formRow'}>
                        <p className='mainText'>USUÁRIO</p>
                    </div>
                    <div className={'formRow'}>
                        <input type='text' name='username' value={username} onChange={(handleUsernameChange)}></input>
                    </div>
                    <div className={'formRow'}>
                        <p className='mainText'>SENHA</p>
                    </div>
                    <div className={'formRow'}>
                        <input type='text' name='password' value={password} onChange={(handlePasswordChange)}></input>
                    </div>
                    <div style={{display: 'flex', marginTop:'15%', gap: '1rem'}}>
                        <button onClick={handleLogin}>ENTRAR</button>
                        <button onClick={handleRegister}>REGISTRAR</button>
                    </div>
                </form>
            </div>
            <div className='homeRow'>
                <p className='mainText'>{output}</p>
            </div>
        </div>
    );
    
};

export default Home;