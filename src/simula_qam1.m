function [ber, numBits] = simula_qam1(EbNo, maxNumErrs, maxNumBits)
    
    %Funció i Sortida
    %   La línia de dalt defineix una funció que es diu simula_qam1 que simula
    %   una transmissió de 4-QAM (o QPSK) a un canal AWGN
    %   Entrades:
    %       EbNo: relació d'energia per bit a densitat de soroll (en dB)
    %       maxNumErrs: nombre màxim d'errors a acumular abans de parar la
    %       simulació
    %       maxNumBits: nombre màxim de bits a simular.
    %   Sortides:
    %       ber: taxa d'error de bits (Bit Error Rate)
    %       numBits: nombre total de bits processats a la simulació
    
    
    %Verificació del nombre d'arguments:
    %   Aquesta instrucció comprova que la funció es truqui amb exactament 3
    %   arguments. Si no és així, es llença un error.
    narginchk(3,3) 
    
    
    %Ús de funcions extrínseques:
    %   Això indica a MATLAB Coder que la funció isBERToolSimulationStopped no
    %   es compilarà (es tractarà com una funció externa).
    %   En simulacions amb BERTool es permet que l'usuari interrompi la
    %   simulació, i aquesta funció comprova aquesta condició.
    coder.extrinsic('isBERToolSimulationStopped')
    
    %Inicialització de variables de control
    %   S'inicialitzen a zero les variables:
    %       totErr: acumulador del nombre total d'errors detectats
    %       numBits: acumulador del nombre total de bits simulats
    %   A simulacions Monte Carlo es necessiten comptadors per determinar quan
    %   s'han aconseguit els llindars preestablerts
    totErr  = 0; % Number of errors observed
    numBits = 0; % Number of bits processed
    
    
    %Mapeig de símbols a bits
    %   Es defineix l'assignació de cada símbol de la constel·lació a una
    %   seqüència de bits
    %   Es fa servir codi Gray, de manera que els símbols veïns difereixin en
    %   un sol bit, minimitzant l'error en cas de desviament
    %   Cada fila correspon a un símbol al mateix ordre que en 'constel_symb'
    
    constelBits = ['00';   % 1+1i
                   '01';   % -1+1i
                   '11';   % -1-1i
                   '10'];  % 1-1i
    
    
    %Definició de la constel·lació 4-QAM (QPSK) normalitzada:
    %   Es defineixen els 4 símbols complexos que representen la constel·lació de
    %   QPSK
    %   Es multiplica per 1/2 per normalitzar la potència mitjana a 1
    %   La normalització és important perquè la potència del senyal sigui
    %   consistent i es pugui relacionar correctament amb la potència del
    %   soroll (Pn). A QPSK, els símbols sense normalitzar tenen magnitud.
    %   2^(1/2) normalitzar-los assegura que E[|s|^2]=1
    constelSymb = (1/sqrt(2)) * [ 1+1i; -1+1i; -1-1i; 1-1i ];
    
    
    %Número de símbols
    %   Es calcula cantidadSimbolos, que és el nombre de punts de la constel·lació
    %   En aquest cas cantidadSimbolos=4
    cantidadSimbolos = length(constelSymb);
    
    
    %Bits per símbol:
    %   Es calcula el nombre de bits que es poden representar amb cada símbol,
    %   fent servir la fórmula bitsSimbolo=log2(cantidadSimbolos)
    %   Per cantidadSimbolos=4, bitsSimbolo=2
    %   Aquest paràmetre és clau per determinar l'eficiència de la modulació
    %   (més bits per símbol implica major eficiència espectral, però també major
    %   susceptibilitat al soroll)
    bitsSimbolo = log2(cantidadSimbolos);
    
    %Número de bits per bloc
    %   Defineix quants bits se simularan a cada iteració del bucle (bloc de
    %   simulació)
    %   Aquí se simulen 10000 símbols, i per això el nombre de bits en cada bloc
    %   serà de 10000*k (on k = 2)
    nbitsBloc = 10000 * bitsSimbolo;
    
    
    %Potència del senyal
    %   Es calcula la potència mitjana del senyal transmès Ps
    %   S'utilitza la mitja del quadrat del valor absolut de cada símbol
    %   La potència del senyal és fonamental per determinar el nivell de soroll
    %   necessari en funció de la relació Eb/N0
    Ps = mean( abs(constelSymb) .^ 2);
    
    %Conversió de dB a lineal
    %   Converteix el valor de Eb/N0 de decibels (dB) al seu valor lineal
    %   mitjançant la fórmula 10^(EbNo/10)
    pRuidoEbNo = 10 ^ (EbNo / 10);
    
    %Càlcul de la potència del soroll
    %   Es calcula Pn, la potència del soroll, fent servir la relació:
    %   Pn=(Ps)/(k*(Eb/E0))
    %   Donat que l'energia per bit Eb es pot obtenir com (considerant el Ts=1)
    %   Eb=Ps/k
    %   i sabent que Eb/N0 no és la raó de senyal a soroll, es pot deduir que:
    %   N0=Eb/(Eb/N0)
    %   En aquesta simulació, es fa servir Pn com una aproximació del soroll
    %   que s'afegeix al senyal
    Pn = Ps / (pRuidoEbNo * bitsSimbolo);
    
    %Longitud del bloc de símbols
    %   Es defineix numSymb com el nombre de símbols que se simularan a cada iteració
    %   del bucle
    numSymb = 10000;    
    
    %Bucle de simulació
    %   S'entra en un bucle que continuarà simulant blocs de transmissió fins
    %   que:
    %       - S'hagin acumulat almenys maxNumErrs errors
    %       - S'hagin transmès almenys maxNumBits
    %   Aquest mètode de parada (criteri d'error o de bits) és típic a
    %   simulacions Monte Carlo per garantir resultats estadísticament
    %   significatius sense excedir temps de processament excessius
    while((totErr < maxNumErrs) && (numBits < maxNumBits))
    
        % Check if the user clicked the Stop button of BERTool.
        % ==== DO NOT MODIFY ====
    
        %Detecció de parada manual
       %   Es comprova si l'usuari ha sol·licitat detenir la simulació
       %   Si és així surt del bucle
        if isBERToolSimulationStopped()
            break
        end
        % ==== END of DO NOT MODIFY ====
      
        % --- Proceed with simulation.
        % --- Be sure to update totErr and numBits.
        % --- INSERT YOUR CODE HERE.
    
        %Generació de símbols a transmetre
        %   Es genera un vector de numSymb nombres sencers aleatoris entre 1 i cantidadSimbolos
        %   Cada nombre representa l'índex d'un símbol de la constel·lació
        %   La generació aleatòria assegura que cada símbol es transmeti amb
        %   una igual probabilitat, simulant una font d'informació equiprobable
        txSymb = randi([1 cantidadSimbolos], 1, numSymb);      %vector de los indices de los simbolos que queremos enviar
    
        %Mapeig d'índex a símbols
        %   S'utilitza el vector 'txSymb' per seleccionar els símbols
        %   corresponents de 'contel_symb'
        %   Això genera el vector del senyal transmès, on cada posició conté
        %   un valor complex de la constel·lació
        txSig = constelSymb(txSymb);
        
    
        %Generació del soroll AWGN
        %   Es genera un vector de soroll complex
        %   randn(1, numSymb) produeix numSymb mostres de soroll gaussià real amb mitja 0 i
        %   variància 1
        %   Es genera soroll per les parts real i imaginària, i es multiplica
        %   per (PN/2)^(1/2) per ajustar la variància de cada component
        %   En un canal AWGN, el soroll es complex, i la potència total es
        %   reparteix equitativament entre la part real i la part imaginària
        Soroll = sqrt(Pn / 2) * (randn( 1, numSymb) + 1i * randn( 1, numSymb)); 
    
        %Senyal rebut
        %   El senyal rebut rxSig és la suma del senyal transmès (convertida en
        %   vector columna amb la transposició ') i el soroll generat
        %   Això simula el pas del senyal per un canal AWGN, on s'afegeix
        %   soroll blanc gaussià al senyal transmès
        rxSig =  txSig.' + Soroll; 
        
        %Demodulació i càlcul d'errors
        %   Es truca a la funció demodqam per demodular el senyal rebut
        %   La funció compara el senal rebut rxSig amb la constel·lació definida
        %   (constel_symb) i el mapeig de bits (constel_bits)
        %   Es calcula el nombre d'errors (nerrors) comparant els bits del
        %   símbol transmés (fent servir txSymb) amb els bits detectats
        %   La demodulació per mínima distància (o detector de màxima
        %   versemblança) és el mètode que es fa servir per decidir quin va ser
        %   el símbol transmès a partir del senyal amb soroll
    
        [detSym_idx, nerrors] = demodqam(rxSig, constelSymb, constelBits, txSymb);
    
        %Acumulació de bits transmesos
        %   S'incrementa el comptador total de bits simulats a la quantitat
        %   corresponent al bloc actual 'nbitsBloc'
        %   Això permet calcular la taxa d'error com la relació entre errors i
        %   bits totals processats
        %   Això permet calcular la taxa d'error com la relació entre errors i
        %   bits totals processats
        numBits = numBits + nbitsBloc;
    
        %Acumulació d'errors
        %   S'actualitza el comptador total d'errors sumant els errors
        %   detectats en aquest bloc
        totErr = totErr + nerrors;
        
    end
    
    %Càlcul final del BER
    %   Es calcula la taxa d'error de bits (BER) dividint el número total
    %   d'errors acumulats entre el nombre total de bits simulats
    %   El BER és una mesura fonamental a comunicacions digitals, indicant la
    %   fracció de bits erronis rebuts. Un BER menor indica un sistema més.
    %   robust enfront del soroll
    ber = totErr/numBits;