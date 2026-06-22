/* commande  pour mettre en oeuvre GDDS            */
             CMD        PROMPT('Mise en Oeuvre GDDS')
             PARM       KWD(LIBPGM) TYPE(*NAME) LEN(10) +
                          SPCVAL((*PARAM)) MIN(1) +
                          PROMPT('Bibliothèque du programme')
             PARM       KWD(LIBCMD) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Bibliothèque de la commande') +
                          SPCVAL((*PARAM))
             PARM       KWD(NUMPGM) TYPE(*CHAR) LEN(2) RSTD(*NO) +
                          DFT(64) RANGE(01 99) MIN(0) +
                          PROMPT('Numéro premier programme')
             PARM       KWD(CRTDSPF) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(O) VALUES(O N) PROMPT('Traiter la +
                          commande CRTDSPF')
             PARM       KWD(CRTPRTF) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(O) VALUES(O N) PROMPT('Traiter la +
                          commande CRTPRTF')
             PARM       KWD(CRTPF) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(N) VALUES(O N) PROMPT('Traiter la +
                          commande CRTPF')
             PARM       KWD(CRTLF) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(N) VALUES(O N) PROMPT('Traiter la +
                          commande CRTLF')

