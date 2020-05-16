CLEARSCREEN.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

SET GM TO CONSTANT:G * BODY:MASS.

// SemiMajorAxis
SET s_SMA TO SHIP:ORBIT:SEMIMAJORAXIS.
SET t_SMA TO TARGET:ORBIT:SEMIMAJORAXIS.

// Distance travelled round the orbit
SET s_OD TO 2 * CONSTANT:PI * s_SMA.
SET t_OD TO 2 * CONSTANT:PI * t_SMA.

// Orbital Velocity
SET s_OV TO SQRT( GM / s_SMA ).
SET t_OV TO SQRT( GM / t_SMA ).

// Orbital Period
SET s_OP TO SHIP:ORBIT:PERIOD.
SET t_OP TO TARGET:ORBIT:PERIOD.

// Angular Velocity
SET s_AV TO 360 / s_OP.
SET t_AV TO 360 / t_OP.
SET diffAV TO t_AV - s_AV.
//Credit to kOS Discord user nuggreat for a better equation here

SET transferTime TO CONSTANT:PI * SQRT( (s_SMA + t_SMA)^3 / (8 * GM) ).

SET transferAngle TO 180 - ( 360 * transferTime / t_OP ).
IF transferAngle < 0 {
	SET transferAngle TO transferAngle + 360.
}
//PRINT transferAngle.

SET deltaVoutbound TO SQRT( 2 * GM * ( t_SMA / ( s_SMA * ( s_SMA + t_SMA ) ) ) ) - s_OV.
//PRINT deltaVoutbound.

//SET deltaVinbound TO ( s_SMA / t_SMA ) * SQRT( 2 * GM * ( t_SMA / ( s_SMA * ( s_SMA + t_SMA ) ) ) ) - t_OV.
//PRINT deltaVinbound.

SET s_LoAN TO SHIP:ORBIT:LONGITUDEOFASCENDINGNODE.
SET t_LoAN TO TARGET:ORBIT:LONGITUDEOFASCENDINGNODE.

SET s_AoP TO SHIP:ORBIT:ARGUMENTOFPERIAPSIS.
SET t_AoP TO TARGET:ORBIT:ARGUMENTOFPERIAPSIS.

SET s_TA TO SHIP:ORBIT:TRUEANOMALY.
SET t_TA TO TARGET:ORBIT:TRUEANOMALY.

SET s_Angle TO s_LoAN + s_AoP + s_TA.
SET t_Angle TO t_LoAN + t_AoP + t_TA.
// Credit to kOS Discord user TheGreatFez for assitance here

SET phaseAngle TO t_Angle - s_Angle.

// transferAngle = ( N * diffAV) + phaseAngle
SET N TO (transferAngle - phaseAngle) / diffAV.

PRINT ROUND(N) + "s".

LOCAL timeToNode IS N + TIME:SECONDS.
ADD NODE(timeToNode,0,0,deltaVoutbound).

// Requires my maneuvernode.ks script
RUN maneuvernode.


