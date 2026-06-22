             CMD        PROMPT('Historique des compiles GDDS')
             PARM       KWD(DATE) TYPE(*CHAR) LEN(10) +
                          DFT(*CURRENT) RANGE('2019-01-01' +
                          '9999-12-31') SPCVAL((*CURRENT)) MIN(0) +
                          PROMPT('Date Format *iso (ssaa-mm-jj)')
