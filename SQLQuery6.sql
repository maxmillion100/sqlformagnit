declare @tTestTable1 table (
ID integer,
DayID date,
ArtID integer,
CntrID integer,
EndQnty decimal(16, 3)
)

Insert into @tTestTable1 values 
(1, '2019-05-10', 1, 2, 10.000),
(2, '2019-05-11', 1, 2, 10.000),
(3, '2019-05-12', 1, 2, 10.000),
(4, '2019-05-13', 1, 2, 10.000),
(5, '2019-05-14', 1, 2, 10.000),
(6, '2019-05-15', 1, 2, 8.000),
(7, '2019-05-16', 1, 2, 8.000),
(8, '2019-05-17', 1, 2, 5.000);

With Sales as
(Select *,case When lag(EndQnty) over (Partition by ArtID Order by DayID, ID) <= EndQnty Then 0 else 1 End as IsSale From @tTestTable1),
Groups as 
(Select *,sum(IsSale) Over (Partition by ArtID Order by DayID, ID) as Grp From Sales)

Select ID,DayID,ArtID,CntrID,EndQnty,
DATEDIFF(d,
isnull(min(DayID) over (Partition by ArtID,Grp Order by DayID, ID Rows between UNBOUNDED PRECEDING and 1 PRECEDING),
       lag(DayID) over (Partition by ArtID,IsSale Order by grp)),
DayID) as DaysPrevSales
 From Groups
Order by ArtID,DayID,id