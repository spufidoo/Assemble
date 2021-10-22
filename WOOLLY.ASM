         TITLE  'SKELETON ASSEMBLER PROGRAM'                            00050000
         PRINT  ON,NODATA,NOGEN                                         00060000
******************************************************************      00070000
*                                                                *      00080000
*   PROGRAMMER:  WOOLBRIGHT                                      *      00090000
*   COMMENTS  :  ASM SKELETON PROGRAM                            *      00100000
*                                                                *      00110000
******************************************************************      00120000
*                                                                *      00130000
*     REGISTER EQUATES                                           *      00140000
*                                                                *      00150000
******************************************************************      00160000
R0       EQU   0                                                        00170000
R1       EQU   1                                                        00180000
R2       EQU   2                                                        00190000
R3       EQU   3                                                        00200000
R4       EQU   4                                                        00210000
R5       EQU   5                                                        00220000
R6       EQU   6                                                        00230000
R7       EQU   7                                                        00240000
R8       EQU   8                                                        00250000
R9       EQU   9                                                        00260000
R10      EQU   10                                                       00270000
R11      EQU   11                                                       00280000
R12      EQU   12                                                       00290000
R13      EQU   13                                                       00300000
R14      EQU   14                                                       00310000
R15      EQU   15                                                       00320000
******************************************************************      00330000
*                                                                *      00340000
*     SYMBOLIC EQUATES                                           *      00350000
*                                                                *      00360000
******************************************************************      00370000
SINGLE   EQU   X'09'      WRITE AND SPACE 1                             00380000
DOUBLE   EQU   X'11'      WRITE AND SPACE 2                             00390000
******************************************************************      00400000
******************************************************************      00410000
WOOLLY   CSECT                         STANDARD ENTRY CODE              00420004
         STM   R14,R12,12(R13)                                          00430000
         BASR  R12,R0                  ESTABLISH...                     00440000
         USING *,R12                   ADDRESSABILITY                   00450000
         ST    R13,SAVEAREA+4          BACKWARD CHAIN CALLER            00460000
         LA    R13,SAVEAREA            ADDRESS OF MY SAVE AREA          00470000
******************************************************************      00480000
* BEGIN THE PROGRAM LOGIC. FIRST OPEN THE INPUT AND OUTPUT FILES        00490000
******************************************************************      00500000
         OPEN  (PRINTER,(OUTPUT))                                       00510000
         OPEN  (FILEIN,(INPUT))                                         00520000
         MVI   PRC1,DOUBLE             PREPARE TO DOUBLE SPACE HEADER   00530000
         PUT   PRINTER,PRHEAD          PRINT THE HEADER                 00540000
         GET   FILEIN,RECORDIN         GET THE FIRST RECORD, IF THERE   00550000
         MVI   PRC2,SINGLE             PREPARE TO SINGLE SPACE REPORT   00560000
*                                                                       00570000
*        READ AND PRINT LOOP                                            00580000
*                                                                       00590000
LOOP     EQU   *                                                        00600000
         MVC   DATAPR,RECORDIN         MOVE INPUT RECORD TO OUTPUT REC  00610000
         PUT   PRINTER,PRINT           PRINT THE RECORD                 00620000
         GET   FILEIN,RECORDIN         GET THE NEXT RECORD              00630000
         B     LOOP                    GO BACK AND PROCESS              00640000
*                                                                       00650000
*        END OF INPUT PROCESSING                                        00660000
*                                                                       00670000
EXIT     EQU   *                                                        00680000
         CLOSE (FILEIN)                CLOSE THE FILES...               00690000
         CLOSE (PRINTER)                                                00700000
         L     R13,SAVEAREA+4          POINT AT OLD SAVE AREA           00710000
         LM    R14,R12,12(R13)         RESTORE THE REGISTERS            00720000
         LA    R15,0                   RETURN CODE = 0                  00730000
         BR    R14                     RETURN TO OPERATING SYSTEM       00740000
******************************************************************      00750000
*                                                                *      00760000
*     OUTPUT FILE - DATA CONTROL BLOCK                           *      00770000
*                                                                *      00780000
******************************************************************      00790000
PRINTER  DCB   DSORG=PS,                                               X00800000
               MACRF=(PM),                                             X00810000
               DEVD=DA,                                                X00820000
               DDNAME=PRINTER,                                         X00830000
               RECFM=FM,                                               X00840000
               LRECL=133                                                00850000
******************************************************************      00860000
*                                                                *      00870000
*     INPUT FILE - DATA CONTROL BLOCK                            *      00880000
*                                                                *      00890000
******************************************************************      00900000
FILEIN   DCB   DSORG=PS,                                               X00910000
               MACRF=(GM),                                             X00920000
               DEVD=DA,                                                X00930000
               DDNAME=FILEIN,                                          X00940000
               EODAD=EXIT,                                             X00950000
               RECFM=FB,                                               X00960000
               LRECL=80                                                 00970000
******************************************************************      00980000
*                                                                       00990000
*    INPUT RECORD AREA                                                  01000000
*                                                                       01010000
******************************************************************      01020000
RECORDIN DS    CL80                                                     01030000
******************************************************************      01040000
*                                                                       01050000
*    OUTPUT RECORD AREA                                                 01060000
*                                                                       01070000
******************************************************************      01080000
*                                                                       01090000
*      HERE IS THE HEADER                                               01100000
*                                                                       01110000
******************************************************************      01120000
PRHEAD   DS   0CL133                                                    01130000
PRC1     DC    CL1' '              PRINT CONTROL                        01140000
         DC    CL10' '                                                  01150000
         DC    CL122'*** MY FIRST ASSEMBLER PROGRAM ***'                01160000
*                                                                       01170000
******************************************************************      01180000
*                                                                       01190000
*    OUTPUT RECORD AREA                                                 01200000
*                                                                       01210000
******************************************************************      01220000
PRINT    DS   0CL133              PRINT AREA                            01230000
PRC2     DC    C' '               PRINT CONTROL CHARACTER               01240000
         DC    CL10' '                                                  01250000
DATAPR   DC    CL80' '                                                  01260000
         DC    CL42' '                                                  01270000
******************************************************************      01280000
*                                                                       01290000
*    REGISTER SAVE AREA                                                 01300000
*                                                                       01310000
******************************************************************      01320000
SAVEAREA DS  18F                                                        01330000
******************************************************************      01340000
*                                                                       01350000
*    LITERAL POOL                                                       01360000
*                                                                       01370000
******************************************************************      01380000
         LTORG *                                                        01390000
         END   WOOLLY                                                   01400004