      SUBROUTINE TSTORG
C	TRANSPORT BLOCK
C	CALLED BY ROUTE NEAR LINE 521
C=======================================================================
C     ROUTINE TO COMPUTE NEW STORAGE VOLUME AND OUTFLOW FOR
C     STORAGE UNIT IN THE TRANSPORT BLOCK.
C     USES STORAGE-INDICATION (MODIFIED PULS) ROUTING.
C
C     MODIFIED FOR TRANSPORT BLOCK BY S.J.NIX, SEPTEMBER 1981.
C     REVISED, JANUARY 1983
C     REVISED, NOVEMBER 1992 BY WCH TO CORRECT SUBSCRIPTS FOR A1,A2,D0
C     WCH (RED), 9/23/93.  FIX TWO IF-STMTS.
C     WCH, 10/6/93.  ALTER WAY OF COMPUTING STORL().
C     WCH (STEVE MERRILL), 3/28/94.  SAVE DEPTHL FOR OUTPUT USING I2 
C       LINES.  
C     WCH (RED), 12/20/94.  CHECK FOR POSSIBLE POWER EQUATION OUTFLOW
C       > VALUE CALCULATED BY LINEAR INTERPOLATION.  ALSO, ADD NEW 
C       COMMENT LINES.  
C=======================================================================
      INCLUDE 'TAPES.INC'
      INCLUDE 'HUGO.INC'
      INCLUDE 'NEW81.INC'
      INCLUDE 'TST.INC'
C=======================================================================
C#### WCH (Steve Merrill), 3/28/94.  Remove DEPTHL. Include in TST.INC.
      DIMENSION SURGE2(NET),SDE(17),SST(17)
      DIMENSION SAO(17),SAT(17),SSTOP(NTSE),A1(NTSE),
     +         A2(NTSE),KLIST(NTSE),ION(NTSE)
      EQUIVALENCE (SURGE2(1),P2(1)),(A1,B1),(A2,B2)
      DATA KLIST/NTSE*0/
C=======================================================================
      QOUST  = 0.0
      QOUST1 = 0.0
      QOUST2 = 0.0
      DEPTH  = 0.0
      FLOOD  = 0.0
      IS     = KSTORE(M)
      MINT   = MINTS(IS)
      IF(QINST+STORL(IS).LE.0.0.AND.N.GE.1) GO TO 200
C=======================================================================
C     INITIALIZATION IS DONE WHEN CALLED FROM SUB INITAL (VIA ROUTE)
C     WHEN CALLED FROM INITAL, N = 0.
C=======================================================================
      SO2DT2    = 0.0
C=======================================================================
C     STORE CURRENT DEPTH AND STORAGE ARRAYS INTO SDE AND SST FOR 
C     LATER LINEAR INTERPOLATION.  
C=======================================================================
      DO 110 MM = 1,MINT
      SDE(MM)   = TSDEP(IS,MM)
  110 SST(MM)   = TSTORE(IS,MM)
      IF(N.GE.1) GO TO 200
C=======================================================================
C     ESTABLISH INITIAL CONDITIONS BASED ON INITIAL VOLUME, STORL.  
C=======================================================================
      ION(IS)    = 0
C#### WCH, 10/6/93.  SET STORE() = STORL() INITIALLY.
      STORE(IS)  = STORL(IS)
      QINSTL(IS) = 0.0
      QOUSTL(IS) = 0.0
      DEPTHL(IS) = 0.0
C+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      IF(LOUT(IS).GE.3) CALL TINTRP(SDE,SST,MINT,TDSTOP(IS),SSTOP(IS))
C+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      IF(STORL(IS).GT.0.0)CALL TINTRP(SST,SDE,MINT,STORL(IS),DEPTHL(IS))
C+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
C     HERE, START ROUTINE TIME-STEP COMPUTATIONS.
C=======================================================================
C#### WCH, 10/6/93.  SET VALUE OF STORL HERE INSTEAD OF AT END.
  200 STORL(IS) = STORE(IS)
      IF(QINST+STORL(IS).LE.0.0) GO TO 500
      MIN = 1
      IF(LOUT(IS).LE.2) GO TO 210
C=======================================================================
C     DEFINE PUMPING RATES.
C=======================================================================
      IF(DEPTHL(IS).LE.TDSTOP(IS))   ION(IS) = 0
C#### WCH (RED), 9/93.  SHOUD BE STRICTLY GT.
      IF(DEPTHL(IS).GT.TDSTAR(IS,1)) ION(IS) = 1
      IF(DEPTHL(IS).GE.TDSTAR(IS,2)) ION(IS) = 2
      IF(DEPTHL(IS).LE.TDSTAR(IS,1).AND.ION(IS).EQ.2) ION(IS) = 1
      KKK = ION(IS)
      IF(ION(IS).GT.0) SO2DT2 = TQPUMP(IS,KKK)*DT/2.0
      SAT(MIN)  = SSTOP(IS) + SO2DT2
      SAT(MINT) = SST(MINT) + SO2DT2
      GO TO 300
C=======================================================================
C     HERE, NO PUMPS.  SET UP STORAGE-INDICATION ROUTING EQUATION.
C=======================================================================
  210 DO 220 MM = 1,MINT
      SAO(MM)   = TSQOU(IS,MM)*DT/2.0
      SAT(MM)   = SST(MM) + SAO(MM)
      IF(SAO(MM).LE.0.0) MIN = MM
  220 CONTINUE
C=======================================================================
C     HERE, CALCULATE KNOWN LHS OF STORAGE-INDICATION CONTINUITY EQN.
C=======================================================================
  300 STERMS = (QINST+QINSTL(IS)-QOUSTL(IS))*DT/2.0 + STORL(IS)
C#### WCH (RED), 9/93.  ADD FINAL CHECK IN IF-STMT.
      IF(STERMS.LE.SAT(MIN).AND.QOUSTL(IS).GT.0.0.AND.QINSTL(IS).GT.0.0) 
     1             STERMS = SAT(MIN)
C=======================================================================
C     CHECK FOR SURCHARGE.  IF LHS = RHS > MAXIMUM, CALCULATE FLOOD 
C     VOLUME AND STORE AS SURCHARGE AT END OF SUBROUTINE.  
C=======================================================================
      IF(STERMS.LE.SAT(MINT)) GO TO 350
      FLOOD  = QINST*DT - TSQOU(IS,MINT)*DT
      STERMS = SAT(MINT)
C=======================================================================
C     PRINT SURCHARGE MESSAGE EVERY 10TH OCCURRENCE.  
C=======================================================================
      KLIST(IS) = KLIST(IS) + 1
      IF(KLIST(IS).EQ.1.OR.MOD(KLIST(IS),10).EQ.0) THEN
             IF(JCE.EQ.0) WRITE(N6,340) NOE(M),N,FLOOD,KLIST(IS)
             IF(JCE.EQ.1) WRITE(N6,341) KOE(M),N,FLOOD,KLIST(IS)
             ENDIF
C
  350 IF(STERMS.LE.0.0001) STERMS = 0.0
      IF(LOUT(IS).GE.3) GO TO 410
C=======================================================================
C     HERE, DO STORAGE-INDICATION INTERPOLATION TO GET SO2DT2 USING 
C     KNOWN LHS = STERMS.  SKIP IF USING PUMPS.
C     LHS = RHS = STERMS = NEW STORAGE + NEW OUTFLOW*DT/2 = 
C     STORE + SO2DT2.  THEN NEW STORAGE = STERMS - SO2DT2.
C     ARRAYS SAO AND SAT CONTAIN CORRESPONDING VALUES OF QOUT*DT/2 AND
C     STORAGE + QOUT*DT/2, RESPECTIVELY, FOR INTERPOLATION. 
C+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      CALL TINTRP(SAT,SAO,MINT,STERMS,SO2DT2)
C+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  410                        STORE(IS) = STERMS - SO2DT2
      IF(STORE(IS).LE.0.001) STORE(IS) = 0.0
      QOUST = SO2DT2*2.0/DT
C=======================================================================
C     KNOWING NEW STORAGE, INTERPOLATE TO GET NEW DEPTH.
C+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      CALL TINTRP(SST,SDE,MINT,STORE(IS),DEPTH)
C+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      QOUST1 = 0.0
C=======================================================================
C     QOUST = TOTAL OUTFLOW.  IF TWO OUTLETS, GIVEN BY POWER EQUATION
C     FOR EACH, CALCULATE OUTFLOW FROM SECOND OUTLET (= QOUST1 !) USING
C     POWER EQUATION AND SUBTRACT FROM TOTAL TO GET FLOW FROM 
C     SECOND OUTLET (= QOUST2 !).
C=======================================================================
C### WCH, 11/3/92
C CHANGE SUBSCRIPTS FOR A1,A2 AND D0 FROM 2 TO IS
C###
      IF(LOUT(IS).EQ.2.AND.DEPTH.GT.D0(IS))
     1 QOUST1  = A1(IS)*(DEPTH-D0(IS))**A2(IS)
                        QOUST2 = QOUST - QOUST1
      IF(QOUST2.LE.0.0) QOUST2 = 0.0
C=======================================================================
C#### WCH (RED), 12/20/94.  ADD CHECK TO BE SURE QOUST1 <= QOUST. 
C     QOUST1 COULD EXCEED QOUST SLIGHTLY BECAUSE OF LINEAR INTERPOLATION 
C     USED TO GET TOTAL OUTFLOW, QOUST, VS. POWER EQN. USED TO GET 
C     QOUST1.   
C=======================================================================
      IF(QOUST1.GT.QOUST) QOUST1 = QOUST
C=======================================================================
C     NEED TO SAVE STORAGE AND INFLOW FROM THIS TIME STEP TO USE AS 
C     "OLD" VALUES AT NEXT TIME STEP.  BUT STILL NEED OLD STORAGE FOR
C     QUALITY ROUTING, SO DON'T REPLACE IT YET!
C#### WCH, 10/6/93.  CAN'T HAVE STORL = STORE FOR QUALITY ROUTING.
C####                SET STORL AT BEGINNING OF TSTORG, NOT HERE.
C####  500 STORL(IS)  = STORE(IS)
C=======================================================================
  500 QOUSTL(IS) = QOUST
      QINSTL(IS) = QINST
      DEPTHL(IS) = DEPTH
      SURGE2(M)  = FLOOD
      RETURN
C=======================================================================
  340 FORMAT (' ===> WARNING !! FROM SUB TSTORG.  STORAGE UNIT ',I10,
     1' IS FLOODING.  EXCESS VOLUME BEING STORED AS SURCHARGE.',/,
     2 7X,'TIME STEP = ',I6,'.  FLOOD VOLUME = ',1PE14.7,' CU FT.',
     3' OCCURRENCE # ',I6)
  341 FORMAT (' ===> WARNING !! FROM SUB TSTORG.  STORAGE UNIT ',A10,
     1' IS FLOODING.  EXCESS VOLUME BEING STORED AS SURCHARGE.',/,
     2 7X,'TIME STEP = ',I6,'.  FLOOD VOLUME = ',1PE14.7,' CU FT.',
     3' OCCURRENCE # ',I6)
C=======================================================================
      END
