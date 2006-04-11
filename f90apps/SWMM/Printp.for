      FUNCTION PRINTP1(IPUMP,VVWELL)
C	EXTRAN BLOCK
C
C   Finds pumping rate for VWELL for IPTYP 1 pumps.
C   Note that VRATES increase and are checked in INDAT2.FOR.
C
C   Created by C. Moore, CDM  5/97
C
      INCLUDE 'TAPES.INC'
      INCLUDE 'WEIR.INC'
      DO 100 K = 1, NPRATE(IPUMP)-1
      KK = K
  100 IF (VVWELL.LT.VRATE(IPUMP,KK)) GO TO 200
      KK = NPRATE(IPUMP)
  200 TEMP = PRATE(IPUMP,KK)
      CONTINUE
cim  WRITE(n6,*) 'PRINTP1',VVWELL,TEMP
      PRINTP1 = TEMP
      RETURN
      END
C
C
      FUNCTION PRINTP2(IPUMP,YDEP)
C
C   Finds pumping rate for YDEP for IPTYP 2 pumps.
C   Note that VRATES increase and are checked in INDAT2.FOR.
C
C   Created by C. Moore, CDM  5/97
C
      INCLUDE 'TAPES.INC'
      INCLUDE 'WEIR.INC'
      DO 100 K = 1, NPRATE(IPUMP)-1
      KK = K
  100 IF (YDEP.LT.VRATE(IPUMP,KK)) GO TO 200
      KK = NPRATE(IPUMP)
  200 TEMP = PRATE(IPUMP,KK)
  300 CONTINUE
cim   WRITE(n6,*) 'PRINTP2',YDEP,TEMP
      PRINTP2 = TEMP
      RETURN
      END
C
C
C
      FUNCTION PRINTP3(IPUMP,DH)
C
C   Linearly interpolate to find pumping rate for DH for IPTYP 3 pumps.
C   Note that VRATES decrease and are checked in INDAT2.FOR.
C
C   Created by C. Moore, CDM  5/97
C
      INCLUDE 'TAPES.INC'
      INCLUDE 'WEIR.INC'
      IF(DH.GE.VRATE(IPUMP,1)) THEN
      TEMP = PRATE(IPUMP,1)
      GO TO 300
      ENDIF
      DO 100 K = 2, NPRATE(IPUMP)
      KK = K
  100 IF (DH.GT.VRATE(IPUMP,KK)) GO TO 200
cim gets here if DH is less than last VRATE
      TEMP = PRATE(IPUMP,NPRATE(IPUMP))
      GO TO 300
  200 RATIO = (DH-VRATE(IPUMP,KK-1))/
     a        (VRATE(IPUMP,KK)-VRATE(IPUMP,KK-1))
      TEMP = PRATE(IPUMP,KK-1) +
     a         RATIO * (PRATE(IPUMP,KK)-PRATE(IPUMP,KK-1))
  300 CONTINUE
cim   WRITE(n6,*) 'PRINTP3',DH,TEMP
      PRINTP3=TEMP
      RETURN
      END


      FUNCTION PRINTP4(IPUMP,YDEP)
C
C   Interpolates to find pumping rate for YDEP for IPTYP 4 pumps.
C   Note that VRATES increase and are checked in INDAT2.FOR.
C
C   Created by C. Moore, CDM  5/97
C
      INCLUDE 'TAPES.INC'
      INCLUDE 'WEIR.INC'
	IF(IPOPR(1,IPUMP).EQ.-1) THEN
C PUMP WAS OFF
	IF(YDEP.LT.PON(IPUMP)) THEN
C PUMP STAYS OFF
	PRINTP4 = 0.0
	RETURN
	ELSE
C PUMP COMES ON
	IPOPR(1,IPUMP) = 1
	GO TO 50
	ENDIF
	ELSE
C PUMP WAS ON
	IF(YDEP.GT.POFF(IPUMP)) THEN
C PUMP STAY ON
	GO TO 50
	ELSE
C PUMP TURNS OFF
	IPOPR(1,IPUMP) = -1
	PRINTP4 = 0.0
	RETURN
	ENDIF
	ENDIF
   50 CONTINUE
      DO 100 K = 2, NPRATE(IPUMP)
      KK = K
  100 IF (YDEP.LT.VRATE(IPUMP,KK)) GO TO 200
      TEMP = PRATE(IPUMP,NPRATE(IPUMP))
      GO TO 300
  200 RATIO = (YDEP-VRATE(IPUMP,KK-1))/
     1        (VRATE(IPUMP,KK)-VRATE(IPUMP,KK-1))
      IF (RATIO.LT.0.0) RATIO = 0.0
      TEMP = PRATE(IPUMP,KK-1) +
     1          RATIO * (PRATE(IPUMP,KK)-PRATE(IPUMP,KK-1))
  300 CONTINUE
cim   WRITE(n6,*) 'PRINTP4',YDEP,TEMP
      PRINTP4 = TEMP
      RETURN
      END

	FUNCTION PRINTP5(IPUMP,YDEP)
C  RETURNS PUMPING RATE FOR TYPE 5 PUMPS
C
C  CREATED BY C MOORE CDM 6/99
	INCLUDE 'TAPES.INC'
	INCLUDE 'WEIR.INC'
      INCLUDE 'CONTR.INC'
	TEMP = 0.0
	DO K = 1,NPRATE(IPUMP)
	IF(IPOPR(K,IPUMP).EQ.1) GO TO 500
C     HERE PUMP WAS OFF
C	CHECK IF IT STAYS OFF
	IF (YDEP.LT.VRATE(IPUMP,K)) THEN  ! Pump Stays Off
	QPUMP = 0.0
	ELSE   ! Turn Pump on
	IPOPR(K,IPUMP) = 1
	TRATIO = AMIN1(TIMEON(K,IPUMP)/PONDELAY(IPUMP),1.0)
	QPUMP = TRATIO * PRATE(IPUMP,K)
	TIMEON(K,IPUMP) = TIMEON(K,IPUMP) + DELT/2.0
	ENDIF
	GO TO 600
C   
  500 CONTINUE
C     HERE PUMP WAS ON
C     CHECK THAT IT STAYS ON 
	IF (YDEP.LT.POFF(IPUMP)) THEN   !TURN PUMP OFF AND RESET STUFF
	QPUMP = 0.0
	IPOPR(K,IPUMP) = -1
	TIMEON(K,IPUMP) = 0.0
	ELSE         ! PUMP STAYS ON
	TRATIO = AMIN1(TIMEON(K,IPUMP)/PONDELAY(IPUMP),1.0)
	QPUMP = TRATIO * PRATE(IPUMP,K)
	TIMEON(K,IPUMP) = TIMEON(K,IPUMP) + DELT/2.0
	ENDIF
  600 CONTINUE
	TEMP = TEMP + QPUMP
	enddo
	PRINTP5 = TEMP
	RETURN
		END FUNCTION PRINTP5
