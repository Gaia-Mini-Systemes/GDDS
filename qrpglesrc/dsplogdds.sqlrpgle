**free
     //
     // Liste des logs GDDS
     //
Ctl-Opt DFTACTGRP(*NO);
Dcl-f DSPLOGDDS  WORKSTN  indds(DS_Ind) SFILE(sfl01:rang ) usropn;
 // DDS information programme
dcl-ds *N PSDS ;
  nom_du_pgm CHAR(10) POS(1);
  init_user  CHAR(10) POS(254);
End-ds ;
 // Déclaration des indicateurs
dcl-ds DS_Ind len(99) ;
  Ind_Sortie                        ind pos(3) ;
  Ind_Liste                         ind pos(4) ;
  Ind_Reaffichage                   ind pos(5) ;
  Ind_Creer                         ind pos(6) ;
  Ind_Validation                    ind pos(10) ;
  Ind_Annuler                       ind pos(12) ;
  Ind_SFLCLR                        ind pos(40) ;
  Ind_SFLDSP                        ind pos(41) ;
  Ind_SFLDSPCTL                     ind pos(42) ;
  Ind_SFLEND                        ind pos(43) ;
  Ind_Protect                       ind pos(81) ;
END-DS;
// les paramètres recus
dcl-pi *N ;
  P_DATE char(10);
end-pi ;
// Déclaration des variables de travail
dcl-s maxrang  PACKED(4 : 0) ;
dcl-s error ind ;
dcl-s sqlstmt char(1024)  ;
     // Option de compile SQL
Exec SQL
  Set Option
    Naming    = *Sys,
    Commit    = *None,
    UsrPrf    = *User,
    DynUsrPrf = *User,
    Datfmt    = *iso,
    CloSqlCsr = *EndMod;
 // Si paramètre pas recu on met à date du jour
   if %parms() = 0 ;
     w_date =%DATE() ;
   else ;
     Trait_parm() ;
   endif ;
  // Contrôle taille Ecran
  Monitor ;
    Open DSPLOGDDS  ;
    On-error ;
      dsply 'Nécessite un écran 27 * 132' ;
      *inlr = *on ;
    Return  ;
  Endmon  ;
     // Structure du programme
  Init_SFL();
  Load_SFL();
  Display_SFL();
     // Fin du programme
  *inlr = *on;
     // Procédure d'initialisation
dcl-proc Init_SFL ;
  exec sql
    select count(*) into :nb_enr from loggdds    ;
  num01 = 1                           ;
  rang  = 0                           ;
  opt01 = ' '                       ;
  Ind_SFLCLR = *on                    ;
  write ctl01                         ;
  Ind_SFLEND = *on                    ;
  Ind_SFLCLR = *off                   ;
end-proc ;
     // Procédure de chargement
dcl-proc Load_SFL        ;
Exec Sql
declare curs01 cursor  for SELECT
Loguser , Logdate , logtime , logcmd
FROM loggdds
        where logdate >= :w_date
ORDER BY logdate  desc, logtime  desc
;
Exec Sql
close curs01 ;
Exec Sql
open curs01 ;
dou   sqlcode <> 0 ;
  exec sql
  fetch
  from curs01
  into
:Loguser , :Logdate , :logtime , :logcmd
;
  if  sqlcode =  0 ;
    rang  = rang  + 1 ;
    maxrang  = rang   ;
    cmd90   = logcmd             ;
    write sfl01 ;
  endif;
enddo;
end-proc ;
       // Affichage du format de controle
dcl-proc Display_SFL     ;
  Ind_SFLDSP = *on   ;
  dou Ind_Sortie  ;
    if rang  > 0 ;
      Ind_SFLDSPCTL = *on ;
    else ;
      Ind_SFLDSPCTL = *off;
    endif ;
    write fmt01  ;
    exfmt ctl01  ;
    if Ind_Sortie ;
      leave ;
    endif ;
    select ;
      //    Réaffichage
    when Ind_Reaffichage ;
      Init_SFL()  ;
      Load_SFL()  ;
      Display_SFL() ;
      //    Création
    Other ;
      // Traitement du sous fichier
      if Ind_SFLDSPCTL ;
        readc sfl01  ;
        if not %eof() ;
          select     ;
  // afficher erreur
            when opt01 = '5';
  //        path256 = LXMLPATH ;
              Traitement() ;
          endsl;
          opt01 = ' ';
          update(e) sfl01;
        endif;
      endif ;
    endsl ;
  enddo  ;
end-proc ;
     // fonction de traitement
dcl-proc Traitement ;
  dou Ind_Annuler or Ind_Sortie ;
    exfmt fmt02 ;
    if Ind_Sortie  or Ind_Annuler;
      Leave ;
    endif  ;
  enddo  ;
end-proc ;
//
// * traitement du parametre date
//
dcl-proc Trait_parm ;
  // controle de date
  // si pas de - on ajoute
  if p_date = '*CURRENT' ;
    w_date =%DATE();
  else ;
    Monitor;
      if %scan('-':p_date) > 0 ;
        w_date =%DATE(P_date:*ISO);
      else ;
        // si pas de - saisie
        if %subst(p_date:7:2) <> '  ';
          w_date =%DATE(%subst(p_date:1:4) +
              '-' + %subst(p_date:5:2) +
              '-' + %subst(p_date:7:2)) ;
        else ;
          // si pas de siécle saisie
          w_date =%DATE('20' + %subst(p_date:1:2) +
              '-' + %subst(p_date:3:2) +
              '-20' + %subst(p_date:5:2)) ;
        endif;
      endif;
    On-Error *ALL;
      // forcage date du jour
      w_date =%DATE();
    EndMon;
  endif ;
end-proc ;
