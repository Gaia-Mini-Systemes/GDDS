             CMD        PROMPT('Rempl. instruction de compile')

             PARM       KWD(LIBSRC) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Bibliothèque')
             PARM       KWD(FICSRC) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Fichier source')
             PARM       KWD(MBRSRC) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Membre  source')
             PARM       KWD(OLDCHAR) TYPE(*CHAR) LEN(60) +
                          DFT('<COMP>BFFORE</COMP>') MIN(0) +
                          PROMPT('Instruction avant     ')
             PARM       KWD(NEWCHAR) TYPE(*CHAR) LEN(60) +
                          DFT('<COMP>AFTER</COMP>') MIN(0) +
                          PROMPT('Instruction après     ')
