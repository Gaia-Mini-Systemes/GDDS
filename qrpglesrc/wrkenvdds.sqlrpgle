**free
     //
     // Liste des logs GDDS
     //
Ctl-Opt DFTACTGRP(*NO);
Dcl-f WRKENVDDS  WORKSTN  indds(DS_Ind) SFILE(sfl01:rang ) usropn;
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
  Ind_PROTECT                       ind pos(64) ;
END-DS;
// Déclaration des variables de travail
dcl-s maxrang  PACKED(4 : 0) ;
dcl-s error ind ;
dcl-s sqlstmt char(1024)  ;
dcl-s exit_cmdw char(35)  ;
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
    Open WRKENVDDS  ;
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
    FROM QSYS2.EXIT_PROGRAM_INFO WHERE
    EXIT_POINT_NAME = 'QIBM_QCA_CHG_COMMAND'
    ;
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
declare curs01 cursor  for
SELECT EXIT_PROGRAM_NUMBER, EXIT_PROGRAM_LIBRARY, EXIT_PROGRAM,
substr(EXIT_PROGRAM_DATA , 1 , 35), EXIT_POINT_FORMAT
FROM QSYS2.EXIT_PROGRAM_INFO
WHERE EXIT_POINT_NAME = 'QIBM_QCA_CHG_COMMAND'
ORDER BY EXIT_PROGRAM_NUMBER ;
Exec Sql
close curs01 ;
Exec Sql
open curs01 ;
dou   sqlcode <> 0 ;
  exec sql
  fetch
  from curs01
  into
:exit_nbr ,:exit_lib, :exit_pgm, :exit_cmdw , :exit_fmt
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
    select ;
      //    Réaffichage
    when Ind_Reaffichage ;
      Init_SFL()  ;
      Load_SFL()  ;
      Display_SFL() ;
      //    Ajout nouvelle commande
    when Ind_Creer ;
              Traitement() ;
    Other ;
      // Traitement du sous fichier
      if Ind_SFLDSPCTL ;
        readc sfl01  ;
        if not %eof() ;
          select     ;
  // afficher erreur
            when opt01 = '4';
 exec sql
   call qcmdexc('?RMVEXITPGM EXITPNT(QIBM_QCA_CHG_COMMAND) FORMAT(' concat
 trim(:exit_fmt) concat ') PGMNBR(' concat char(:exit_nbr) concat ')') ;
if sqlcode <> 0;
dsply 'retrait en erreur' ;
endif;
            when opt01 = '5';
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
if Ind_Creer ;
IND_PROTECT = *off ;
EXIT_FMT = 'CHGC0100' ;
exec SQL
SELECT max(EXIT_PROGRAM_NUMBER) + 1
INTO :EXIT_NBR
FROM QSYS2.EXIT_PROGRAM_INFO
WHERE EXIT_POINT_NAME = 'QIBM_QCA_CHG_COMMAND' ;
exec sql select
PGMROB,
BIBROB,
BIBCMD
into
:EXIT_PGM,
:EXIT_LIB,
:EXIT_LIBC
from GPARAMGDDS;
else ;
IND_PROTECT = *on ;
EXIT_CMD = %subst(EXIT_CMDW : 1 : 10) ;
EXIT_LIBC = %subst(EXIT_CMDW : 10 : 10) ;
endif ;
  dou Ind_Annuler or Ind_Sortie ;
    exfmt fmt02 ;
    if Ind_Sortie  or Ind_Annuler;
      Leave ;
    endif  ;
 if not IND_PROTECT  ;
 exec sql
call qcmdexc('ADDEXITPGM EXITPNT(QIBM_QCA_CHG_COMMAND) FORMAT(' concat
 trim(:exit_fmt) concat ') PGMNBR(' concat char(:exit_nbr) concat
') PGM(' concat TRIM(:exit_LIB) concat '/' concat
trim(:exit_pgm) concat ') PGMDTA(*JOB 20 ''' concat :exit_cmd concat :exit_libc concat ''')') ;
if sqlcode <> 0;
dsply 'Ajout en erreur' ;
else ;
 Ind_Annuler = *on ;
endif;
endif;
  enddo  ;
end-proc ;
