**FREE
// *--------------------------------------------------------------------
// *
// * Ce programme est associé au point d'exit et il se déclenche à
// * chaque exécution des commandes CRTPRTF, CRTDSPF, CRTPF et CRTLF.
// * Il utilise un programme RTVMBRSRC qui DOIT se trouver dans la
// * liste des bibliothèques.
// *
// *--------------------------------------------------------------------
// déclaration des paramètres recus
Dcl-PI *N;
  wParam1            Char(32000);
  Replace_String     Char(32000);
  Replace_Length     Bindec(9);
End-PI;

// commande à traiter
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

 // chaine de remplacement
// longueur de la commande renvoyée
// Variables de travail
Dcl-S SrcDta         Char(80);
Dcl-S CmdSQL         Char(512);
Dcl-S P_Lib          Char(10);
Dcl-S P_Fil          Char(10);
Dcl-S P_Mbr          Char(10);
Dcl-S Format_String  Char(32000);
dcl-s rep char(1);

Dcl-PR  RTVMBRSRC EXTPGM('RTVMBRSRC');
  P_Data             Char(3200);
  P_Lib              Char(10);
  P_Fil              Char(10);
  P_Mbr              Char(10);
End-PR;

// initialisation des options de compile sql
  EXEC SQL
          Set Option
            Naming    = *Sys,
            Commit    = *None,
            UsrPrf    = *User,
            DynUsrPrf = *User,
            Datfmt    = *iso,
            CloSqlCsr = *EndMod;

// Récupération de la commande recue
Param1 = wParam1;
Format_String  =  %subst(Param1 : (Offset + 1) : Command_length);
Format_String  = 'QSYS/' + Format_String;

// Récupération de la bibliothèque du membre source
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

// Création d'un alias pour lecture du membre source
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

// Restitution de la commande implémentée des options du source
Replace_String = Format_String;
Replace_Length = %len(%trim(Replace_String));

// Fin du programme
*inlr = *on;
