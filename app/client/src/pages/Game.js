import { useEffect, useState, useRef } from 'react';
import { currSector, moveToSector, findNearbySectors, pilotStatus, showGameMap } from '../connection/api';
import Typewriter from '../components/Typewriter';
import './style.css';

const Game = () => {
    const [errMessage, setErrMessage] = useState('');
    const [userInput, setUserInput] = useState('');
    const [messages, setMessages] = useState([`Bem-vindo ao TERRAN_OS. Todos os sitemas online.`]);
    const [notices, setNotices] = useState([]);
    const [contentFile, setContentFile] = useState('basicShip.txt');

    const [displayContent, setDisplayContent] = useState('');

    const scrollRef = useRef(null);

    // MANTÉM O TEXTO EMBAIXO
    useEffect(() => {
        if(scrollRef.current){
            scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
        }
    }, [messages, notices]);

    const getPilotStatus = async() => {
        try {
            const response = await pilotStatus();
            setNotices(response);
        } catch (err) {
            setErrMessage(err.response.data.error);
        }
    };
    
    const move = async(direction) => {
        try {
            const response = await moveToSector({direction});
            setNotices(response);
        } catch (err) {
            setErrMessage(err.response.data.message);
        }   
    };

    const showMap = async() => {
        try{
            const response = await showGameMap();
            setNotices(response);
        } catch (err) {
            setErrMessage(err.response.data.message);
        }
    }
    
    const handleCommands = (input) => {
        let command = input.split(' ')[0];
        switch (command){
            case 'limpar':
                setMessages(['']);
                return `Limpando memória.`; 
            case 'nav':
                let direction = input.split(' ');
                if(direction[1]){
                    move(direction[1]);
                    return `Coordenadas definidas para direção ${direction[1]}.`;
                } else {
                    return 'Esse comando espera uma das direções: norte, sul, leste, oeste.'
                }
            case 'status':
                getPilotStatus();
                return '### SOLICITANDO STATUS DO PILOTO';
            case 'mapa':
                showMap();
                return '### SOLICITANDO MAPA DA GALÁXIA'
            default:
                return 'Comando inexistente.';
        }
    };

    const handleUserInput = (e) => {
        setUserInput(e.target.value);
    };

    const handleUserSubmit = (e) => {
        if(e.key === 'Enter'){
            e.preventDefault();
            const result = handleCommands(userInput);
            console.log(notices);

            if(Array.isArray(result)){
                setMessages((prevMsgs) => [...prevMsgs, '>> '+userInput  ]);
                result.forEach(item => {
                    setMessages((prevMsgs) => [...prevMsgs, item]);
                });
            } else {
                setMessages((prevMsgs) => [...prevMsgs, '>> '+userInput  ]);
                setMessages((prevMsgs) => [...prevMsgs, result]);
            }

            document.getElementById('userInput').value = '';
        }
    };

    useEffect(() => {
        notices.forEach(item => {
            setMessages((prevMsgs) => [...prevMsgs, item]);
        });
    }, [notices])

    useEffect(() => {
        fetch('/' + contentFile)
        .then((response) => response.text())
        .then((text) => setDisplayContent(text))
        .catch((err) => console.log('File error: ', err));
    });

    return(
        <div className='gameContainer'>
            <div className='gameColumn'>
                {/* <pre ref={asciiTextRef} className='mainTitle'></pre> */}
                <pre className='displayContent'>{displayContent}</pre>
            </div>
            <div className='terminalColumn'>
                <div className='terminalContent' ref={scrollRef}>
                    {messages.slice(0,-1).map(item => (
                        <p className='displayTerminalText'>{item}</p>
                    ))}
                    <Typewriter className='displayTerminalText' text={messages.slice(-1)[0]} speed={20}/>
                </div>
                <div className='terminalInput'>
                    <input autoComplete='off' id='userInput' style={{width: '100%'}} onChange={handleUserInput} onKeyDown={handleUserSubmit}></input>
                </div>
            </div>
            <div className='gameColumn'>
            </div>
        </div>
    );       
};

export default Game;