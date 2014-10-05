//*****************************
/// \author Sébastien Lemoine
/// \date Septembre 2014
/// \brief Fonctions nécessaires à la génération de la documentation
//******************************


//****************************************************************************
/// \fn indexer_Fichier(tabBalises, stcDoc, debugActif)
/// \brief Idexe les lignes d'un fichier
/// \param [in] tabBalises
/// \param [in] stcDoc
/// \param [in] debugActif  \c Booléen    Afficher plus d'info en console
/// \param [out] stcDoc
//*****************************************************************************
function indexer_Fichier(tabBalises, stcDoc, debugActif)
    // Ouvrir le fichier
    // Chemin
    cheminFichierCourant = strcat([fnctPath,'\', ...
                stcDoc.fichiers.tab(stcDoc.fichiers.indexFichierCourant).nom]);
    // Ouvrir
    mopen(cheminFichierCourant,'r'); // Ouverture du fichier
    // Copier
    stcFichierCourant = struct("contenu", "");
    contenu = mgetl(cheminFichierCourant);  // Lecture du fichier
    // Fermer
    mclose(cheminFichierCourant);  // Fermeture du fichier

    /// \TODO Afficher une barre de progression
    indexer_Ligne(contenu, stcDoc, tabBalises,  debugActif);
    
    // Trier les noms des fonctions par ordre croissant
//    listeNomsFonctions = stcDoc.fichiers.tab(stcDoc.fichiers.indexFichierCourant).tabFonctions.nom;
//    for i=1:dimensions(listeNomsFonctions,"ligne");
//        strListeNomsFonctions(i) = string(listeNomsFonctions(i));
//    end
//    listeNomsFonctionsTrie = gsort(strListeNomsFonctions,'lr','i');
    
    [stcDoc] = return(stcDoc);
endfunction



//****************************************************************************
/// \fn indexer_Ligne(contenu, stcDoc, tabBalises, debugActif)
/// \brief Idexe les lignes d'un fichier
/// \param [in] contenu
/// \param [in] indexLigne
/// \param [out] indexLigne
/// \param [out] stcContenu
/// \param [in] debugActif  \c Booléen    Afficher plus d'info en console
//*****************************************************************************
function indexer_Ligne(contenu, stcDoc, tabBalises, debugActif)
    indexFichier = stcDoc.fichiers.indexFichierCourant;
    nomFichier = stcDoc.fichiers.tab(indexFichier).nom;
    // Nombre de fonctions
    stcDoc.fichiers.tab(stcDoc.fichiers.indexFichierCourant).nbr = 0;
    
    // Indexation précédente
    stcContenu_1 = struct("nom","");
    estFonction = %f;
    
    indexLigne = 1;
    while (indexLigne <= dimensions(contenu, "ligne"))
    //      for indexLigne = 1:9
        try
    //        printf("ligne %i\n",indexLigne);
            // 2ème condition pour éviter d'indexer la ligne
            if (grep(contenu(indexLigne),"/// ") == 1 &...
                grep(contenu(indexLigne),"grep(contenu") <> 1) then
                stcContenu = extraire_Balise(contenu(indexLigne));
                // Si pas de balise alors texte sur plusieurs lignes
                if ~stcContenu.contientBalise then
                    stcContenu.nom = stcContenu_1.nom;
                end
                // si le nom de la balise est reconnue alors extract sinon erreur
                
                // Todo
                if convstr(stcContenu.nom,'u') == convstr(tabBalises(1),'u') then
                    if ~stcContenu.contientBalise then
                        // Concaténer avec la ligne précédente
                        while grep(contenu(indexLigne),"/// ") == 1
                            stcContenu = extraire_Balise(contenu(indexLigne));
                            textePrecedent = stcDoc.todo.tab(stcDoc.todo.nbr).descr;
                            stcDoc.todo.tab(stcDoc.todo.nbr).descr = descr_2_Lignes(...
                                                    textePrecedent, stcContenu, %f);
                            indexLigne = indexLigne+1;
                        end
                        indexLigne = indexLigne-1;
                    else
                        stcDoc.todo.nbr = stcDoc.todo.nbr + 1;
                        stcDoc.todo.tab(stcDoc.todo.nbr).fichier = nomFichier;
                        stcDoc.todo.tab(stcDoc.todo.nbr).ligne = indexLigne;
                        stcDoc.todo.tab(stcDoc.todo.nbr).descr = stcContenu.descr;
                    end
    
                // Bug
                elseif convstr(stcContenu.nom,'u') == convstr(tabBalises(2),'u') then
                    stcDoc.bug.nbr = stcDoc.bug.nbr + 1;
                    stcDoc.bug.tab(stcDoc.bug.nbr).fichier = nomFichier;
                    stcDoc.bug.tab(stcDoc.bug.nbr).ligne = indexLigne;
                    stcDoc.bug.tab(stcDoc.bug.nbr).descr = stcContenu.descr;
                
                // Version
                elseif stcContenu.nom == tabBalises(3) then
                    stcDoc.fichiers.tab(indexFichier).version = stcContenu.descr;
                
                // Author
                elseif stcContenu.nom == tabBalises(4) then
                    stcDoc.fichiers.tab(indexFichier).auteur = stcContenu.descr;
               
                // Date
                elseif stcContenu.nom == tabBalises(5) then
                    stcDoc.fichiers.tab(indexFichier).date = stcContenu.descr;
                
                // Brief
                elseif stcContenu.nom == tabBalises(6) then
                    // Brief d'une fonction
                    if estFonction then
                        // Attrapper errerr si \fn manquant
                        try
                            // Sur plusieurs lignes
                            if ~stcContenu.contientBalise then
                                // Concaténer avec la ligne précédente
                                textePrecedent = stcDoc.fichiers.tab(...
                                        indexFichier).tabFonctions(nbrFonctions).resume;
                                stcContenu.descr = descr_2_Lignes (textePrecedent, stcContenu);
                            end
                            stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                        nbrFonctions).resume = stcContenu.descr;
                        catch
                            printf("Erreur \t Ligne %d: Balise ''fonction'' manquante\n",...
                                    indexLigne);
                        end
    
                    // Brief du fichier
                    else
                        // Sur plusieurs lignes
                        if ~stcContenu.contientBalise then
                            // Concaténer avec la ligne précédente
                            temp1 = stcDoc.fichiers.tab(indexFichier).resume;
                            temp2 = stcContenu.descr;
                            stcContenu.descr = strcat([temp1, temp2]);
                        end
                        stcDoc.fichiers.tab(indexFichier).resume = stcContenu.descr;
                        if stcDoc.fichiers.tab(indexFichier) == [] then
                            stcDoc.fichiers.tab(indexFichier).date="";
                        end
                        if stcDoc.fichiers.tab(indexFichier) == [] then
                            stcDoc.fichiers.tab(indexFichier).version="";
                        end
                    end
                
                // Fonction
                elseif stcContenu.nom == tabBalises(7) then
                    // Initialisation
                    nbrFonctions = stcDoc.fichiers.tab(indexFichier).nbr +1;
                    stcDoc.fichiers.tab(indexFichier).nbr = nbrFonctions;
                    // Si première fonction du fichier
                    try
                        stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                            nbrFonctions).nom="";
                    catch
                        stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                nbrFonctions) = struct("nom","");
                    end
                    stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                        nbrFonctions).param="";
                    stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                        nbrFonctions).resume="";
                    stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                        nbrFonctions).retourne="";
                    
                    // Proto
                    stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                    nbrFonctions).proto = stcContenu.descr;
                    // Ligne
                    stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                    nbrFonctions).ligne = indexLigne;
    
                    // Nom
                    if grep(stcContenu.descr,'(') == 1 then
                        nom = part(stcContenu.descr, 1:strcspn(stcContenu.descr,'('));
                            if grep(nom,'=') == 1 then
                                nom = part(nom,strcspn(stcContenu.descr,'=')+2:length(nom));
                            end
                    else
                        printf("Erreur \t Ligne %d: prototype mal interprété\n",...
                               indexLigne);
                        nom = "";
                    end
                    
                    stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                    nbrFonctions).nom = nom;
                    // Init nombre de paramètres
                    stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                    nbrFonctions).nbrparam = 0;
                    estFonction = %t;
                
                // Param
                 elseif stcContenu.nom == tabBalises(8) then
                    nbrparam = stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                    nbrFonctions).nbrparam +1;
                    stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                    nbrFonctions).nbrparam = nbrparam;
                    stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                    nbrFonctions).param(nbrparam) = stcContenu.descr;
                
                // Return
                elseif stcContenu.nom == tabBalises(9) then
                    // Sur plusieurs lignes
                    if ~stcContenu.contientBalise then
                        // Concaténer avec la ligne précédente
                        temp1 = stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                    nbrFonctions).retourne;
                        temp2 = stcContenu.descr;
                        stcContenu.descr = strcat([temp1, temp2]);
                    end
                    stcDoc.fichiers.tab(indexFichier).tabFonctions(...
                                    nbrFonctions).retourne = stcContenu.descr;
    
                // Balise non reconnue
                else
                    printf("Erreur \t Ligne %d: Balise non reconnue\n",indexLigne);
                end
                // Sauvegarde de l'indexation courante
                stcContenu_1 = stcContenu;
            end
        catch
            printf("Erreur \t Problème avec le fichier ''%s'' à la ligne %i\n",...
                    nomFichier, indexLigne);
            if  debugActif then
                pause
            end
        end
        indexLigne = indexLigne +1;
    end
    
    [stcDoc] = resume(stcDoc);
endfunction



//****************************************************************************
/// \fn stcContenu = extraire_Balise(contenuLigne)
/// \brief Localise et extrait le nom de la balise et sa description
/// \param [in] contenuLigne    \c string   Ligne à analyser
/// \return stcContenu    \c structure    Nom et description de la balise
//*****************************************************************************
function stcContenu = extraire_Balise(contenuLigne)
    stcContenu = struct("contientBalise",%f);
    finContenu = length(contenuLigne);
    
    // Localiser nom balise et description
    debutPosNom = strcspn(contenuLigne,"\")+2;
    // Si '\' trouvé
    if debutPosNom < finContenu then
        finPosNom = strcspn(part(contenuLigne,debutPosNom:finContenu),' ')+debutPosNom;
        
        // Extraire nom et description
        stcContenu.contientBalise = %t;
        stcContenu.nom = part(contenuLigne,debutPosNom:finPosNom-1);
        stcContenu.descr = part(contenuLigne,finPosNom+1:finContenu);
    else
        stcContenu.nom = "";
        debutPos = posi_Dern_Slash(contenuLigne, finContenu);
        stcContenu.descr = part(contenuLigne, debutPos+1:finContenu);
    end
endfunction


//****************************************************************************
/// \fn estcontenu = est_Mot_Contenu(tableau, mot)
/// \brief Test l'existance d'un mot dans un tableau
/// \param [in] tableau    \c tabString   Tableau contenant le mot recherché
/// \param [in] mot    \c String   Mot recherché
/// \return estcontenu    \c booléen    True si mot appartient à tableau
//*****************************************************************************
function estcontenu = est_Mot_Contenu(tableau, mot)
    estcontenu = %f;
    for index = 1:dimensions(tableau,"ligne");
        if mot == tableau(index) then
            estcontenu = %t;
            return
        end
    end
endfunction


//****************************************************************************
/// \fn tabBalises = liste_Nom_Balises()
/// \brief Tableau contenant la liste des balises
/// \return tabBalises    \c tabString    Liste des noms de balise
//*****************************************************************************
function tabBalises = liste_Nom_Balises()
    tabBalises(1) = "todo";
    tabBalises(2) = "bug";
    tabBalises(3) = "version";
    tabBalises(4) = "author";
    tabBalises(5) = "date";
    tabBalises(6) = "brief";
    tabBalises(7) = "fn";
    tabBalises(8) = "param";
    tabBalises(9) = "return";
endfunction

//****************************************************************************
/// \fn dernPosi = posiDernAntiSlash(contenuLigne, finContenu)
/// \brief Detecte la position de "///"
/// \return dernPosi    \c double    position du 3ème '/'
//*****************************************************************************
function dernPosi = posi_Dern_Slash(contenuLigne, finContenu)
    for i = 1:finContenu-2
        if part(contenuLigne,i:i+2) == "///" then
            dernPosi = i+2;
            return
        end
    end
endfunction


//****************************************************************************
/// \fn temp12 = descr_2_Lignes (temp1, stcContenu)
/// \brief Concaténer temp1 avec stcContenu.descr
/// \param [in] textePrecedent \c String    Texte avec lequel concaténer
/// \param [in] stcContenu \c Structure     Structure de la documentation
/// \param [in] opt_multiLignes \c boolen   Si présent, temp12 est sur plusieurs lignes
/// \return temp12    \c string    Chaine concaténée
//*****************************************************************************
function temp12 = descr_2_Lignes (textePrecedent, stcContenu, opt_multiLignes)
    temp2 = stcContenu.descr;
    // Sur plusieurs lignes
    if argn(2) == 3 then
        if textePrecedent == "" then
            temp12 = temp2;
        else
            temp12 = textePrecedent;
            temp12(dimensions(textePrecedent,"ligne")+1,1) = temp2;
        end
    // Sur une seule ligne
    else
        temp12 = strcat([textePrecedent, temp2]);
    end
endfunction


//****************************************************************************
/// \fn listeNomFichiers = supr_Fichiers_Temp(tempListeNomFichiers)
/// \brief Retirer de la liste des fichiers ceux contenant '~'
/// \param [in] tempListeNomFichiers \c tabString    Liste des noms de fichiers
/// \return listeNomFichiers    \c tabString    Liste des noms de fichiers
//*****************************************************************************
function listeNomFichiers = supr_Fichiers_Temp(tempListeNomFichiers)
    j=1;
    for i = 1:dimensions(tempListeNomFichiers,'ligne')
        if grep(tempListeNomFichiers(i),'~') <> 1 then
            listeNomFichiers(j)=tempListeNomFichiers(i);
            j=j+1;
        end
    end
endfunction


//****************************************************************************
/// \fn creer_Documentation(stcDoc, nomProjet, nomFichier, debugActif)
/// \brief Exporte dans un fichier texte la documentation du projet
/// \param [in] stcDoc  \c Structure    Documentation
/// \param [in] debugActif  \c Booléen    Afficher plus d'info en console
//*****************************************************************************
function creer_Documentation(stcDoc, nomProjet, nomFichier, debugActif)
    // Créer et ouvrir le fichier
    [fd, err] = mopen(nomFichier, 'wt');

    // Remplir fichier
    if err == 0 then
        mfprintf(fd,"Documentation du projet: %s\n",nomProjet);
        // Date et heure
        tempDate = getdate();
        mfprintf(fd,"Générée le %i-%s-%s\n",tempDate(1), ...
            nombre_2_Chiffres(tempDate(2)), nombre_2_Chiffres(tempDate(6)));

        mfprintf(fd,"\n********* BUG **********\n");
        if stcDoc.bug.nbr == 0 then
            mfprintf(fd,"Aucun BUG remonté\n");
        else
            ecrireTab(fd, stcDoc.bug);
        end

        mfprintf(fd,"\n********* TODO **********\n");
        if stcDoc.todo.nbr == 0 then
            mfprintf(fd,"Aucun TODO remonté\n");
        else
            ecrireTab(fd, stcDoc.todo);
        end
    
        mfprintf(fd,"\n********* FONCTIONS **********\n");
        ecrireTabFnct(fd, stcDoc.fichiers);

        mfprintf(fd,"\n--- Fin de la documentation ----");
        // Fermer fichier
        mclose(fd);

    else
        printf("Erreur \t Impossible d''ouvrir le fichier %s\n",nomFichier);
    end
endfunction

//****************************************************************************
/// \fn ecrireTab(fd, stcDocPartiel)
/// \brief Ecrire dans le fichier le contenu de stcDocPartiel
/// \param [in] fd  \c FileDesciptor    Fichier de sortie
/// \param [in] stcDoc  \c Structure    Documentation
//*****************************************************************************
function ecrireTab(fd, stcDocPartiel)
    // Parcourir toutes les entrées
    for i=1:stcDocPartiel.nbr
        stcTxt = stcDocPartiel.tab(i);
        mfprintf(fd,"%i - %s\n", i, stcTxt.fichier);
        mfprintf(fd,"%sLigne %i\n",indenter(1),stcTxt.ligne);
        // Si description sur plusieurs lignes
        for j = 1:dimensions(stcTxt.descr,"ligne") 
            mfprintf(fd,"%s%s\n",indenter(1),stcTxt.descr(j));
        end
    end
endfunction


//****************************************************************************
/// \fn strEspaces = indenter(niveau)
/// \brief Retourne un nombre d'espace multiple du niveau de profondeur
/// \param [in] niveau  \c double    Niveau de profondeur
/// \return strEspaces  \c string   Chaine d'espaces
//*****************************************************************************
function strEspaces = indenter(niveau)
    strEspaces = "";
    for i = 1:niveau
        strEspaces =  strcat([strEspaces, "   "]);
    end
endfunction

//****************************************************************************
/// \fn ecrireTabFnct(fd, stcDocPartiel, debugActif)
/// \brief Ecrire dans le fichier le contenu de stcDocPartiel
/// \param [in] fd  \c FileDesciptor    Fichier de sortie
/// \param [in] stcDoc  \c Structure    Documentation
/// \param [in] debugActif  \c Booléen    Afficher plus d'info en console
//*****************************************************************************
function ecrireTabFnct(fd, stcDocPartiel, debugActif)
    // Parcourir toutes les entrées
    /// \todo Trier les fonctions par nom et non par ordre d'apparition
    for i=1:stcDocPartiel.nbr
        try
            stcFichier = stcDocPartiel.tab(i);
            // Fichier
            mfprintf(fd,"%i - %s\n", i, stcFichier.nom);
            if stcFichier.auteur <> [] then
                mfprintf(fd,"%s%s\n", indenter(1), stcFichier.auteur);
            end
            if stcFichier.date <> [] then
                mfprintf(fd,"%s%s\n", indenter(1), stcFichier.date);
            end
            if stcFichier.version <> [] then
                mfprintf(fd,"%sVersion %s\n", indenter(1), stcFichier.version);
            end
            if stcFichier.resume <> [] then
                mfprintf(fd,"%s%s\n", indenter(1), stcFichier.resume);
            end
            
            //Fonctions
            for j = 1:stcFichier.nbr
                stcTxtFonction = stcFichier.tabFonctions(j);
                // Noms
                // 1ère lettre en majuscule
                posi=1;
                while part(stcTxtFonction.nom,posi) == ' '
                    posi=posi+1;
                end
                txt = convstr(part(stcTxtFonction.nom,posi),'u');
                txt = strcat([txt, part(stcTxtFonction.nom, ...
                            posi+1:length(stcTxtFonction.nom))]);
    
                mfprintf(fd,"%s%i - %s\n",indenter(2),j,txt);
                mfprintf(fd,"%sLigne %d\n",indenter(3),stcTxtFonction.ligne);
                mfprintf(fd,"%s%s\n",indenter(3),stcTxtFonction.resume);
                mfprintf(fd,"%s%s\n",indenter(3),stcTxtFonction.proto);
                // Parametres
                if stcTxtFonction.nbrparam > 0 then
                    for k = 1:stcTxtFonction.nbrparam
                        mfprintf(fd,"%s%s\n",indenter(4),stcTxtFonction.param(k));
                    end
                end
                // Retourne
                if stcTxtFonction.retourne <> "" then
                    mfprintf(fd,"%s%s\n",indenter(4),stcTxtFonction.retourne);
                    /// \todo Si plusieurs 'retourne', décomenter le code
        //            for k = 1:stcTxtFonction.nbrRetourne
        //                mfprintf(fd,"%s%s\n",indenter(3), ...
        //                          stcTxtFonction.tabRetourne(k));
        //            end
                end
            end
        catch
            printf("Erreur \t Problème avec le fichier ''%s''\n",stcFichier.nom);
            if  debugActif then
                pause
            end
        end
    end
endfunction
