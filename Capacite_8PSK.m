%%% Nbre de bits %%%
N = 1000;

%%% P�riode symboles %%%
Ts = 4;
N_T =2;
roll_off=0.35;

%%% Puissance � l'entr�e %%%
% rapport signal sur bruit %

Es_N0_dB = [-2:0.2:20];
Es_N0 = 10.^(Es_N0_dB./10);

M = 8;

capacite = [];

for l=1:length(Es_N0_dB)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% Emetteur %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%% G�n�ration d'un dirac %%%
    dirac = eye(1,Ts);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% Codeur %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Param�tres du Codeur %%%
    R = 2/3;
    H = dvbs2ldpc(R);
    enc = fec.ldpcenc(H);
    %%% G�n�ration d'une s�quence de bits 
    suite_bits = randint(1,enc.NumInfoBits,2);
    %%% Codage de la s�quence de bits %%%
    suite_bits_code = encode(enc,suite_bits);



    %%%%%%%%%%%%%%%%%%%%%%%%%%% Entrelaceur %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    index_perm = randperm(length(suite_bits_code));
    suite_bits_emise = suite_bits_code(index_perm);


    %%%%%%%%%%%%%%%%%%%%%%%%%%% Modulateur %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Construire un modulateur 8-PSK
    h1 = modem.pskmod('M',8,'PhaseOffset',pi/8,'SymbolOrder','Gray','InputType','Bit');

    % Matlab modulate function for 8PSK
    suite_symboles = modulate(h1,suite_bits_emise(:));
    suite_symboles = suite_symboles.';

    %%% G�n�ration de la suite d'impulsions de diracs %%%
    signal_in_emetteur = kron(suite_symboles,dirac);
    signal_in_emetteur = [signal_in_emetteur,zeros(1,2*N_T*Ts)];

    %%%%%%%%%%%%%%%%%%%%%%%% Mise en forme %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%% Filtre de mise en forme ou filtre d'�mission %%%
    filtre_emetteur = rcosfir(roll_off,N_T,Ts,Ts,'sqrt');
    filtre_emetteur = filtre_emetteur/norm(filtre_emetteur);

    %%% Signal � la sortie du filtre d'�mission %%%%
    signal_out_emetteur = filter(filtre_emetteur,1,signal_in_emetteur);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% Canal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%% Avec bruit %%%
    var_symboles = var(suite_symboles);

    % Variance bruit %
    sigma2 = var_symboles./(2*Es_N0);

    %%% G�n�ration du bruit %%%
    bruit = sqrt(sigma2(l))*randn(1,length( signal_out_emetteur ))+ 1i*sqrt(sigma2(l))*randn(1,length( signal_out_emetteur ));



    %%%%%%%%%%%%%%%%%%%%%%%%%%% R�cepteur %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%% Filtrage adapt� %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Filtre de r�ception ou filtre adapt� %%%
    filtre_recepteur = filtre_emetteur;

    % signal � l'entr�e du r�cepteur %
    signal_in_recepteur = signal_out_emetteur + bruit;

    %%% Signal � la sortie du filtre de r�ception %%%%
    signal_out_recepteur = filter(filtre_recepteur,1,signal_in_recepteur);

    %%%%%%%%%%%%%%%%%%%%%%%%%% Echantillonneur %%%%%%%%%%%%%%%%%%%%%%%% 
    %%% instant optimal d'�chantillonnage %%%
    t_optimal = 1; %d'apr�s le diagramme de l'oeil

    % Echantillonneur
    signal_out_recepteur_ech = signal_out_recepteur(t_optimal+(2*N_T*Ts):Ts:length(signal_out_recepteur));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%% capacit� du canal %%%%%%%%%%%%%%%%%%%%%%%%
    HX = log2(M);
    X = h1.Constellation;
    PYX = exp(-((abs(signal_out_recepteur_ech.' - suite_symboles.')).^2)/(2*sigma2(l)));
    somme = 0;
    for ii=1:length(X)
        somme = somme + exp(-((abs(signal_out_recepteur_ech.' - X(ii))).^2)/(2*sigma2(l)));
    end
    PXY = PYX./somme;
    HXY = -mean(log2(PXY));
    capacite(l) = HX - HXY;
    
end


plot(Es_N0_dB,capacite,'r-.','linewidth', 2);
hold on;
grid on;



