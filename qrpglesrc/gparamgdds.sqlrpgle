**FREE
ctl-opt DFTACTGRP(*NO) ;
  //
  // Ce programme permet de gérer le fichier des paramètres
  //
  dcl-f
    GPARAMDDSE   WORKSTN   ;
  dcl-f
    GPARAMGDDS
    USAGE(*UPDATE:*OUTPUT)
    rename(GPARAMGDDS:GPARAMF) ;
  dcl-s creat ind ;
  //
  //    lecture du fichier Paramètres
  //
  read GparamGDDS ;
  if   %eof(GPARAMGDDS) ;
    LIBPRD = 'GDDSD'      ;   // bibliothèque du produit
    PGMROB = 'GDDSROBOT'  ;   // nom du programme d'interception
    BIBROB = 'GDDSD'      ;   // Bibliothèque du Programme
    BIBCMD = 'QSYS'       ;   // Bibliothèque des commandes à traiter
    creat = *on ;
  else ;
    creat = *off  ;
  endif ;
  glog = 'GDDS' ;
  // Boucle d'affichage
  dou  *in03 or *in12 ;
    exfmt fmt01 ;
    if not *in03 and not *in12 ;
      // Si F10 mise à jour
      if *in10 ;
        if creat        ;
          write gparamf ;
        else ;
          update gparamf ;
        endif   ;
        setll *start gparamGDDS;
        read  gparamGDDS ;
      endif   ;
    endif;
  enddo ;
//
// Fin du programme
//
*inlr = *on;
