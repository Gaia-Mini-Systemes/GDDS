
**free
     //
     // Liste des logs GDDS
     //
Ctl-Opt DFTACTGRP(*NO);
Dcl-f DSPDDSINSR  WORKSTN  indds(DS_Ind) SFILE(sfl01:rang ) usropn;
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
  P_lib  char(10);
  P_fic  char(10);
  P_mbr  char(10);
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
// Contrôle taille Ecran
  Monitor ;
    Open DSPDDSINSR ;
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
    select count(*) into :nb_enr
    FROM qtemp.lstinst ;
  num01 = 1                           ;
  rang  = 0                           ;
  Ind_SFLCLR = *on                    ;
  write ctl01                         ;
  Ind_SFLEND = *on                    ;
  Ind_SFLCLR = *off                   ;
end-proc ;
// Procédure de chargement
dcl-proc Load_SFL        ;
Exec Sql
declare curs01 cursor  for
SELECT srcseq, srcdat, srcdta
FROM qtemp.lstinst ;
Exec Sql
close curs01 ;
Exec Sql
open curs01 ;
dou   sqlcode <> 0 ;
  exec sql
  fetch
  from curs01
  into
:srcseq, :srcdat, :srcdta
;
  if  sqlcode =  0 ;
    rang  = rang  + 1 ;
    maxrang  = rang   ;
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
    enddo ;
end-proc ;
