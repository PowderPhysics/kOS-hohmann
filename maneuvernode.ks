FUNCTION findISP {
	LIST ENGINES IN eng.
	IF eng:LENGTH = 1 RETURN eng[0]:ISP.
	SET activeEng TO list().
	FOR i IN eng {
		IF i:IGNITION {// AND NOT i:FLAMEOUT{
			activeEng:ADD(i).
		}
	}
	IF activeEng:LENGTH = 1 RETURN eng[0]:ISP.
	SET activeEngT TO 0.
	SET activeEngTI TO 0.
	FOR i IN activeEng {
		SET activeEngT TO activeEngT + i:AVAILABLETHRUST.
		SET activeEngTI TO activeEngTI + (i:AVAILABLETHRUST / i:ISP).
	}
	RETURN activeEngT / activeEngTI.
	//https://forum.kerbalspaceprogram.com/index.php?/topic/60254-liquid-fuel-density/#comment-903851
}

FUNCTION burn_duration {
	PARAMETER ISPs, DV, wMass, sThrust.
	LOCAL dMass IS wMass / (CONSTANT:E^ (DV / (ISPs * 9.80665))).
	LOCAL flowRate IS sThrust / (ISPs * 9.80665).
	RETURN (wMass - dMass) / flowRate.
}

FUNCTION pointAtNode {
	LOCK STEERING TO NEXTNODE:DELTAV.
	LOCK angleError TO VANG(SHIP:FACING:VECTOR,NEXTNODE:DELTAV).
	IF angleError > 5 {
		PRINT "Aligning to Node".
		UNTIL angleError < 5 {
			WAIT 0.
		}
		PRINT "Ship aligned".
		RETURN.
	}
}

FUNCTION warpToNode {
	PARAMETER burnTime, leadTime.
	KUNIVERSE:TIMEWARP:WARPTO(TIME:SECONDS + NEXTNODE:ETA - burnTime - leadTime).
	PRINT "Warping to T-" + leadtime + "s".
}

FUNCTION executeBurn {
	PARAMETER burnTime.
	WAIT UNTIL NEXTNODE:ETA < (1 + (burnTime / 2)).
	SET THROTTLE TO 1.
	WAIT UNTIL NEXTNODE:DELTAV:MAG < 10.
	LOCK THROTTLE TO NEXTNODE:DELTAV:MAG / 10.
	WAIT UNTIL NEXTNODE:DELTAV:MAG < 0.1 OR angleError > 90.
	SET THROTTLE TO 0.
	PRINT "Node completed".
	IF NEXTNODE:DELTAV:MAG < 0.1 REMOVE NEXTNODE.
}

//------------------------------------\\

CLEARSCREEN.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

SET accurateBurnTime TO burn_duration(findISP(), NEXTNODE:DELTAV:MAG, SHIP:MASS, SHIP:AVAILABLETHRUST).

//SET stageDeltaV TO findISP() * 9.80665 * ln(SHIP:MASS / (SHIP:MASS - ((STAGE:LIQUIDFUEL + STAGE:OXIDIZER) * 0.005))).
//IF stageDeltaV < NEXTNODE:DELTAV:MAG SET not_enough_deltaV_program_terminated TO 1 / 0.

SAS OFF.
pointAtNode().
warpToNode(accurateBurnTime, 60).
pointAtNode().
warpToNode(accurateBurnTime, 5).
executeBurn(accurateBurnTime).
SAS ON.