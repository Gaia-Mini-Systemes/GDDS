**FREE
ctl-opt
      DFTACTGRP(*NO) ;
// *--------------------------------------------------------------------
// *
// * Ce programme est associé au point d'exit QIBM_QCA_CHG_COMMAND et il se déclenche à
// * chaque exécution des commandes CRTPRTF, CRTDSPF, CRTPF et CRTLF.
// * si vous les avez declarer
// *
// * C'est un macro langage entre balises
// *
// * <COMP>xxxxxxxxxxxxxx</COMP>
// *
// * exemples :
// * <COMP>RSTDSP(*YES)</COMP>
// * ou
// * <COMP>PAGESIZE(42 166)</COMP>
// * <COMP>LPI(8)</COMP>
// * ou
// * <COMP>LPI(8) PAGESIZE(42 166)</COMP>
// *
// * Remarque :
// * Il y a une restriction système
// * Ca ne marche pas si la commande n'est pas qualifiée en entrée
// * on considére que le fichier LOGGDDS est dans la même bib que
// * le programme
// *
// *--------------------------------------------------------------------
// Déclaration des paramètres recus
Dcl-PI *N;
  PParam1            Char(32000);
  Replace_String     Char(32000);
  Replace_Length     Bindec(9);
End-PI;
// Commande à traiter
Dcl-DS Param1;
  Exit_point_Name    Char(20);
  Exit_point_Format  Char(8);
  Command_Name       Char(10);
  Library_Name       Char(10);
  Change             Ind;
  Prompt             Ind;
  *N                 Char(2);
  Offset             Bindec(9);
  Command_length     Bindec(9);
  command_string     Char(31000);
End-DS;
 // DDS information programme
 dcl-ds *N PSDS ;
   nom_du_pgm CHAR(10) POS(1);
   Bib_pgm   CHAR(10) POS(81);
   init_user  CHAR(10) POS(254);
end-ds;
// Variables de travail
Dcl-S
SrcDta               Char(80);
Dcl-S CmdSQL         Char(512);
Dcl-S P_Lib          Char(10);
Dcl-S P_Fil          Char(10);
Dcl-S P_Mbr          Char(10);
Dcl-S Format_String  Char(32000);
dcl-s rep char(1);
// initialisation des options de compile sql
EXEC SQL
        Set Option
          Naming    = *Sys,
          Commit    = *None,
          UsrPrf    = *User,
          DynUsrPrf = *User,
          Datfmt    = *iso,
          CloSqlCsr = *EndMod;
init_pgm();
// Récupération de la commande recue à traiter
Param1 = PParam1;
Format_String  =  %subst(Param1 : (Offset + 1) : Command_length);
// On execute toujours la commande de QSYS */
  Format_String  = 'QSYS/' + Format_String;
// Récupération de la bibliothèque, du fihhier et du membre source
RTVMBRSRC(Format_String : P_Lib : P_Fil : P_Mbr);
// Si *CURLIB
If P_Lib = '*CURLIB';
  EXEC SQL
       SELECT substr(name, 1, 10)
         INTO :P_Lib
         FROM QSYS2.LIBRARY_LIST_INFO
        WHERE type = 'CURRENT';
  If SqlCode = 100;
    P_Lib = 'QGPL'   ;
  EndIf;
EndIf;
// On va lire les balises des balises du langage GDDS
// pour les ajouter à la commande recue
//
// Création d'un alias pour lecture du membre source de compile
CmdSQL = 'DROP ALIAS QTEMP/INPUT';
EXEC SQL
  EXECUTE IMMEDIATE :CmdSQL;
// si *LIBL
If P_Lib = '*LIBL';
  CmdSQL = 'CREATE ALIAS QTEMP/INPUT FOR ' + %trim(P_Fil) +  ' (' + %trim(P_Mbr) + ')';
Else;
  CmdSQL = 'CREATE ALIAS QTEMP/INPUT FOR ' + %trim(P_Lib) + '/' +
           %trim(P_Fil) + ' (' + %trim(P_Mbr) + ')';
EndIf;
EXEC SQL
  EXECUTE IMMEDIATE :CmdSQL;
// Lecture des lignes du membre source qui contiennent des options de compilation
// du type <COMP>xxxxxxxxxxxxxx</COMP>
EXEC SQL
  CLOSE curs01;

EXEC SQL
  DECLARE curs01 CURSOR FOR
    SELECT substr(SrcDta,
                  (locate('<COMP>', SrcDta) + 6),
                  ((locate('</COMP>', SrcDta) - 1) -
                   (locate('<COMP>', SrcDta) + 5) )
                  ) AS SrcDta
      FROM QTEMP/INPUT
     WHERE SrcDta LIKE ('%<COMP>%')
       AND SrcDta LIKE ('%</COMP>%');
EXEC SQL
  OPEN curs01;
// Boucle de lecture des options de compilation
DoU SqlCode <> 0;
  EXEC SQL
    FETCH FROM curs01 INTO :SrcDta;
  If SqlCode = 0;
    Format_String = %trim(Format_String) + ' ' + %trim(SrcDta);
  EndIf;
EndDo;
// Restitution de la commande complétée des options du source
Replace_String = Format_String;
Replace_Length = %len(Replace_String);
// Historisation des commandes traitées par GDDS
exec sql
 INSERT INTO LOGGDDS VALUES(current user, current date,
current time, trim(:Replace_String)) ;
 if sqlcode <> 0;
   dsply 'Ecriture Log GDDS impossible' ;
 endif;
// Fin du programme
*inlr = *on;
//
// Procédure d'extraction du membre source
//
Dcl-proc RTVMBRSRC;
  Dcl-PI *N;
    P_data       Char(32000);    //I La commande
    P_lib        Char(10);       //O bibliothèque
    P_fil        Char(10);       //O Fichier
    P_mbr        Char(10);       //O Membre
  End-PI;
 //
 // Variables de travail locales
  Dcl-S Pos1     Packed(4:0);
  Dcl-S Pos2     Packed(4:0);
  //
  // Exemple d'un CRTPRTF : CRTPRTF FILE(BIB/NOMPRTF) SRCFILE(LIB/FIL) SRCMBR(MBR)
  // On aura sensiblement la même chose avec les autres CRTxxxF
  // Recherche de "SRCFILE" dans la chaine P_data
  //
  Pos1 = %scan('SRCFILE(' : P_data : 1);

  //Si "SRCFILE(" est dans la commande on va retrouver les noms de bibliothèque et fichier
  If Pos1 > 1;
    // recherche du nom de la bibliothèque source
    Pos2 = %scan('/' : P_data : Pos1);
    // Si un nom de bibliothèque est spécifié on le récupère, c'est la chaine de caractères
    // qui est entre "SRCFILE(" (longueur de 8) et le "/" qui suit.
    // Sinon par défaut les commandes CRTxxxF utilisent *LIBL pour la bibliothèque source
    If Pos2 > 0;
      P_lib = %subst(P_data : Pos1 + 8 : Pos2 - Pos1 - 8);
    Else;
      P_lib = '*LIBL';
      // Positionnement sur le dernier caractère de "SRCFILE(" pour la suite
      Pos2 = Pos1 + 7;
    EndIf;
    // recherche du nom du fichier source
    // recherche du premier ")" à la suite du nom de la bibliothèque trouvée
    Pos1  = %scan(')' : P_data : Pos2);
    P_fil = %subst(P_data : Pos2 + 1 : Pos1 - Pos2 - 1);
  EndIf;
  // recherche SRCMBR  dans la chaine
  Pos1 = %scan('SRCMBR(' : P_data : 1);
  // Le nom du membre source est indiqué
  If Pos1 > 1;
    // Extraction du nom du membre
    Pos2  = %scan(')' : P_data : Pos1);
    //  P_mbr = %subst(P_data : Pos1 + 7 : Pos2 - Pos1 + 7);
    P_mbr = %subst(P_data : Pos1+7 : Pos2 - (Pos1+7));
    // Si le nom du membre est *FILE on va chercher le nom du fichier à compiler
    If P_mbr = '*FILE';
      Pos1 = %scan('FILE(' : P_data : 1);
      If Pos1 > 1;
        // Recherche bibliothèque du fichier à compiler
        Pos2 = %scan('/' : P_data : Pos1);
        // pos2 = 0 => aucun "/" trouvé donc pas de bib qualifiant l'objet
        // le début de l'extraction est après "FILE("
        If Pos2 = 0;
          Pos2 = Pos1 + 5;
        // pos2 <> 0 => prise en compte du "/" trouvé on commencera l'extraction
        // le caractère après ce "/"
        Else;
          Pos2 = Pos2 + 1;
        EndIf;
        // recherche premier ")" après "FILE(" ou "FILE(..../"
        Pos1  = %scan(')' : P_data : Pos2);
        P_mbr = %subst(P_data : Pos2  : Pos1 - Pos2);
      EndIf;
    EndIf;
  Else;
    Pos1 = %scan('FILE(' : P_data : 1);
    // Le mot clé FILE est utilisé
    If Pos1 > 1;
      // recherche bibliothèque du fichier compilé dans le mot clé FILE
      Pos2 = %scan('/' : P_data : Pos1);
      // pos2 = 0 => aucun "/" trouvé donc pas de bib qualifiant l'objet
      // le début de l'extraction est après "FILE("
      If Pos2 = 0;
        Pos2 = Pos1 + 5;
      // pos2 <> 0 => prise en compte du "/" trouvé on commencera l'extraction
      // le caractère après ce "/"
      Else;
        Pos2 = Pos2 + 1;
      EndIf;
      // recherche premier ")" après "FILE(" ou "FILE(..../"
      Pos1  = %scan(')' : P_data : Pos2);
      //    P_mbr = %subst(P_data : (Pos2 +1)  : (Pos1 - (Pos2 + 1) ));
      P_mbr = %subst(P_data : Pos2 : Pos1 - Pos2);
    EndIf;
  EndIf;
End-proc;
//
// Mise en ligne de la bibliothèque si pas présente
//
Dcl-proc Init_pgm ;
exec sql
call qcmdexc('ADDLIBLE ' concat :Bib_pgm concat ' *LAST') ;
if sqlcode <> 0;
endif ;
End-proc;
