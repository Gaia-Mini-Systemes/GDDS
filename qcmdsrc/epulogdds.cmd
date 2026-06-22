             CMD        PROMPT('Epuration Log GDDS')
             PARM       KWD(NBRJOUR) TYPE(*CHAR) LEN(03) RSTD(*NO) +
                          DFT(060) RANGE('001' '999') MIN(0) +
                          PROMPT('Nombre de jours à garder')
