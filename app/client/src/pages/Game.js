import { useEffect, useState, useRef } from 'react';
import { currSector, moveToSector, findNearbySectors } from '../connection/api';
import Typewriter from '../components/Typewriter';
import './style.css';

const Game = () => {
    const [errMessage, setErrMessage] = useState('');
    const [userInput, setUserInput] = useState('');
    const [messages, setMessages] = useState([`Bem-vindo ao TERRAN_OS. Todos os sitemas online.`]);
    const [contentFile, setContentFile] = useState('basicShip.txt');

    const [currentSector, setCurrentSector] = useState('');
    const [currentSectorID, setCurrentSectorID] = useState(null);
    const [nearbySectors, setNearbySectors] = useState({});
    const [displayContent, setDisplayContent] = useState('');

    const [userRequestUpdate, setUserRequestUpdate] = useState(false);

    const scrollRef = useRef(null);

    useEffect(() => {
        if(scrollRef.current){
            scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
        }
    }, [messages]);

    const getNearbySectors = async () => {
        try {
            const response = await findNearbySectors(currentSectorID);
            setNearbySectors(response);
        } catch (err) {
            console.log('aqui; ', err);
            setErrMessage(err.response.error);
        }
    };

    const getCurrentSector = async() => {
        try {
            const response = await currSector();
            setCurrentSector(response.name);
            setCurrentSectorID(response.id);
        } catch (err) {
            setCurrentSector(err.response.data.error);
        }
    };
    
    const move = async(direction) => {
        try {
            await moveToSector({direction});
            await getCurrentSector();
        } catch (err) {
            setErrMessage(err.response.data.message);
        }   
    };
    
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
            case 'setor':
                let flag = input.split(' ');
                if (flag[1] === 'prox'){
                    getNearbySectors();
                    let result = [`Os setores adjacentes de ${currentSector} são:`];
                    if (nearbySectors.north){
                        result.push(`NORTE: ${nearbySectors.north}.`);
                    }
                    if (nearbySectors.south){
                        result.push(`SUL: ${nearbySectors.south}.`);
                    }
                    if (nearbySectors.west){
                        result.push(`OESTE: ${nearbySectors.west}.`);
                    }
                    if (nearbySectors.east){
                        result.push(`LESTE: ${nearbySectors.east}.`);
                    }
                    return result;
                } else {
                    return [`Setor atual: ${currentSector}.`];
                }
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
            setUserRequestUpdate(!userRequestUpdate);
            const result = handleCommands(userInput);
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

    const handleSystemMessage = (msg) => {
        setMessages((prevMsgs) => [...prevMsgs, msg]);
    }

    useEffect(() => {
        fetch('/' + contentFile)
        .then((response) => response.text())
        .then((text) => setDisplayContent(text))
        .catch((err) => console.log('File error: ', err));
    });
    
    useEffect(() => {
        getCurrentSector();
        if(currentSector != ''){
            handleSystemMessage(`Entrando agora no setor ${currentSector}.`);
        }
    }, [currentSector]);

    useEffect(() => {
        if(currentSectorID != null){
            getNearbySectors();
        }
    }, [userRequestUpdate, currentSector]);

    useEffect(() => {
        if(errMessage !== ''){
            handleSystemMessage(`[!]FALHA: ${errMessage}`);
        }
    }, [errMessage]);


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