ABORT 'NO CARRIER'
ABORT 'ERROR'
ABORT 'NO DIALTONE'
ABORT 'BUSY'
ABORT 'NO ANSWER'
SAY "\nSending break to the modem\n"
#'' "\K"
#'' "+++ATH"
'' AT+CPOF
OK ''
SAY "\nGoodbay\n"

