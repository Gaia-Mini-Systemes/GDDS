             CMD        PROMPT('Affichage instruction(s) GDDS')

             PARM       KWD(LIBSRC) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Bibliothèque')
             PARM       KWD(FICSRC) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Fichier source')
             PARM       KWD(MBRSRC) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Membre  source')
             PARM       KWD(AFFICH) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES(*YES *NO) MIN(0) +
                          PROMPT('Affichage     ')
