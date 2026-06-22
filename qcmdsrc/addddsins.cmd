             CMD        PROMPT('Ajout instruction de compile')

             PARM       KWD(LIBSRC) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Bibliothèque')
             PARM       KWD(FICSRC) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Fichier source')
             PARM       KWD(MBRSRC) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Membre  source')
             PARM       KWD(INSTRUCT) TYPE(*CHAR) LEN(60) +
                          DFT('<COMP></COMP>') MIN(0) +
                          PROMPT('Instruction de compile')
