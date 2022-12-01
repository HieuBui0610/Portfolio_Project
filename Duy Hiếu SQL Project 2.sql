use citilink

/* Q1 */

select PlateNo as BusPlate
,format(TDate,'yyyy-MM') as Month
,count(distinct SID) as NumberOfServices
,count(StartTime) as totalNumberOfTrips
,count(DID) as TotalNumberofDrivers
from bustrip
where
	format(TDate,'yyyy-MM') between '2019-07' and '2019-09'
group by PlateNo, format(Tdate,'yyyy-MM')
order by Month ASC, BusPlate ASC


/* Q2 */


select stop.StopID
,stop.LocationDes
,stop.Address
,service.SID
,case 
	when service.Normal = 1 then 'Normal'
	else 'Express'
end as Type
,normal.WeekdayFreq
,normal.WeekendFreq
from stop 
left join stoprank on stoprank.StopID = stop.StopID
left join service on service.SID = stoprank.SID
left join normal on normal.SID = service.SID
where 
	stop.LocationDes like ('%changi%')
order by stop.StopID ASC, service.SID ASC


/* Q3 */


With numberofold as (
Select OldCardID
,count( ride.cardID) as NumberOfRide_Old
from citylink 
left join ride on ride.CardID = citylink.OldCardID
group by OldCardID
)
, replacedID as(
select CardID as replacedCardID
, OldCardID
from citylink
where OldCardID is not null) 

,numberofnew as (
Select replacedID.replacedCardID
,count(ride.cardID) as NumberOfRide_new
from replacedID 
left join ride on ride.CardID = replacedID.replacedCardID
group by replacedID.replacedCardID
)

select non.ReplacedCardID
,citylink.Expiry
,non.NumberOfRide_new
,citylink.OldCardID
,noo.NumberOfRide_Old
from citylink 
right join numberofold as noo on noo.OldCardID = citylink.OldCardID
right join numberofnew as non on non.replacedCardID = citylink.CardID
order by 1 ASC


/* Q4 */

With allBusID as(
Select ride.SID
,YEAR(ride.RDate) as year
, ride.BoardStop as Stop_ID
from ride
where YEAR(ride.RDate) = 2020

UNION

select SID
,YEAR(ride.RDate) as year
,AlightStop as Stop_ID
from ride
where YEAR(ride.RDate) = 2020
)

, TrafficBoard as (
select SID
,BoardStop
,YEAR(ride.RDate) as year 
, count(BoardStop) as ToB
from ride
where YEAR(ride.RDate) = 2020
group by SID,BoardStop,YEAR(ride.RDate)
)

, TrafficAlight as (
select SID
, YEAR(ride.RDate) as year
,AlightStop
,count(AlightStop) as ToA
from ride
where YEAR(ride.RDate) = 2020
group by SID,AlightStop,YEAR(ride.RDate)
)

,toptraffic as(
select allBusID.SID
,allBusID.Stop_ID
,ISNULL(TB.ToB, 0) + ISNULL(TA.ToA,0) as Traffic_cnt
,ROW_NUMBER() over (partition by (allBusID.year), (allbusID.SID) order by ISNULL(TB.ToB, 0) + ISNULL(TA.ToA,0) DESC) as Rank
from allBusID 
full join TrafficBoard as TB on TB.SID = allBusID.SID and TB.BoardStop = allBusID.Stop_ID
full join TrafficAlight as TA on TA.SID = allBusID.SID and TA.AlightStop = allBusID.Stop_ID
where allBusID.SID IS NOT NUll 
	and Stop_ID IS NOT NUll
)

select * 
from toptraffic
where Rank < 4


/* Q5a */


with board as (
select BoardStop
,stop.LocationDes as BoardLocation
from ride
left join stop on stop.StopID = ride.BoardStop )

, alight as (
select AlightStop
,stop.LocationDes as AlightLocation
from ride
left join stop on stop.StopID = ride.AlightStop )

select citylink.CardID
,ride.RDate
,ride.SID
,ride.BoardStop
,BoardLocation
,alight.AlightStop
,alight.AlightLocation
, Sum(stoppair.basefee - stoppair.basefee * cardtype.Discount) as FarePaid
from ride
left join board on board.BoardStop = ride.BoardStop
left join alight on alight.AlightStop = ride.AlightStop
left join stoppair on ride.AlightStop = stoppair.tostop and ride.BoardStop = stoppair.fromstop
left join citylink on citylink.CardID = ride.CardID
left join cardtype on cardtype.Type = citylink.Type
where YEAR(ride.RDate) = 2020
group by citylink.CardID
,ride.RDate
,ride.SID
,ride.BoardStop
,BoardLocation
,alight.AlightStop
,alight.AlightLocation

/* Q5b */


with board as (
select BoardStop
,stop.LocationDes as BoardLocation
from ride
left join stop on stop.StopID = ride.BoardStop )

, alight as (
select AlightStop
,stop.LocationDes as AlightLocation
, case 
when AlightStop is null then max(
from ride
left join stop on stop.StopID = ride.AlightStop )

select citylink.CardID
,ride.RDate
,ride.SID
,ride.BoardStop
,BoardLocation
,alight.AlightStop
,alight.AlightLocation
, Sum(stoppair.basefee - stoppair.basefee * cardtype.Discount) as FarePaid
from ride
left join board on board.BoardStop = ride.BoardStop
left join alight on alight.AlightStop = ride.AlightStop
left join stoppair on ride.AlightStop = stoppair.tostop and ride.BoardStop = stoppair.fromstop
left join citylink on citylink.CardID = ride.CardID
left join cardtype on cardtype.Type = citylink.Type
where YEAR(ride.RDate) = 2020
group by citylink.CardID
,ride.RDate
,ride.SID
,ride.BoardStop
,BoardLocation
,alight.AlightStop
,alight.AlightLocation