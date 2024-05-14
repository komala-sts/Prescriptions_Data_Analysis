--ADB: TASK 2.1
--Step1: Created Database named 'PrescriptionsDB'
USE master ;  
GO  
DROP DATABASE IF EXISTS PrescriptionsDB ;
GO  

CREATE DATABASE PrescriptionsDB;
GO
USE PrescriptionsDB ;  
GO

--Step2: 
--Created Medical_Practice Table
CREATE TABLE Medical_Practice (PRACTICE_CODE nvarchar(50) NOT NULL PRIMARY KEY ,
 PRACTICE_NAME nvarchar(50) NOT NULL,
 ADDRESS_1	nvarchar(50) NOT NULL,
 ADDRESS_2 nvarchar(50) NOT NULL,
 ADDRESS_3	nvarchar(50) NOT NULL,
 ADDRESS_4	nvarchar(50)NOT NULL,
 POSTCODE nvarchar(50) NOT NULL);
 GO

--Created Drugs Table
CREATE TABLE Drugs (BNF_CODE nvarchar(50) NOT NULL PRIMARY KEY ,
 CHEMICAL_SUBSTANCE_BNF_DESCR nvarchar(100),
  BNF_DESCRIPTION nvarchar(150),
  BNF_CHAPTER_PLUS_CODE  nvarchar(100)
);
 GO

-- Created Prescriptions  Table
CREATE TABLE Prescriptions (PRESCRIPTION_CODE nvarchar(50) NOT NULL PRIMARY KEY ,
PRACTICE_CODE nvarchar(50) NOT NULL FOREIGN KEY (PRACTICE_CODE) REFERENCES Medical_Practice (PRACTICE_CODE),
BNF_CODE nvarchar(50) NOT NULL FOREIGN KEY (BNF_CODE) REFERENCES Drugs (BNF_CODE),
QUANTITY decimal,
ITEMS decimal ,
ACTUAL_COST decimal );
  GO
 --Step3: Importing Data into 3 tables from 3 relevant CSV files 
 --Imported Data from drugs.csv file into the Drugs Table
BULK INSERT Drugs 
FROM 'C:\ADB_2023\drugs.csv'
WITH (
	FORMAT = 'CSV',
	FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n');
  GO
  
SELECT * FROM DRUGS;
 GO
 --Imported Data from Medical_Practice.csv file into the Medical_Practice Table
 BULK INSERT Medical_Practice
FROM 'C:\ADB_2023\Medical_Practice.csv'
WITH ( 
	FORMAT = 'CSV',
	FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);
 GO

SELECT * FROM Medical_Practice;
 GO
 --Imported Data from Prescriptions.csv file into the Prescriptions Table
 BULK INSERT Prescriptions
FROM 'C:\ADB_2023\Prescriptions.csv' 
WITH
(
	FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'   
);
GO

Select * from Prescriptions;
GO


 --TASK2.2
 CREATE OR ALTER PROCEDURE List_TabletCapsules
AS
BEGIN
--This Stored Procedure contains 2 Select Queries 
 --1)Query that returns details of all drugs which are in the form of Tablets or Capsules. 
 --implemented using Like operator on BNF_DESCRIPTION column
 --2)This stored procedure will also return the Total number of Tables and Capsules in the BNF_DESCRIPTION column
 --used  CASE expression with Charindex string function CHARINDEX(substring, string, start) and 
 --Finally found the Total using the SUM() Aggregate Function
	SELECT * FROM DRUGS WHERE BNF_DESCRIPTION LIKE '%tablet%' OR BNF_DESCRIPTION LIKE '%capsule%';
	SELECT
	  SUM(CASE WHEN CHARINDEX('tablet', LOWER(BNF_DESCRIPTION),0 )>  0 THEN 1 ELSE 0 END) AS 'NumberOf_Tablets',
	  SUM(CASE WHEN CHARINDEX('capsule', LOWER(BNF_DESCRIPTION),0 )>  0 THEN 1 ELSE 0 END) AS   'NumberOf_Capsules'
	from DRUGS ;
END;
GO

EXEC List_TabletCapsules;
GO

--TASK2.3
CREATE OR ALTER PROCEDURE LIST_Prescription_Total_Qty 
 AS 
BEGIN
--This Stored Procedure contains Select query that returns the Total Quantity for each of the prescriptions 
-- total quantity is calculated by the number of items multiplied by the quantity. 
-- Total Quantities that are not integer values are rounded to the nearest integer value as per Client's requirement
-- TRY CATCH is used inorder to ensure ACID Properties since calculation between column values are involved .
	BEGIN TRY
		SELECT PRESCRIPTION_CODE,	PRACTICE_CODE,	BNF_CODE,	QUANTITY,	
		ITEMS, round(quantity * items ,0) as TOTAL_QUANTITY, ACTUAL_COST
		 FROM Prescriptions;
	 END TRY 
	 BEGIN CATCH 
		 DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int 
		 SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY() RAISERROR(@ErrMsg, @ErrSeverity, 1)
	 END CATCH;
 END;
 GO

EXEC LIST_Prescription_Total_Qty;
 GO

--TASK 2.4
CREATE OR ALTER FUNCTION Get_Chemicals()
RETURNS TABLE
AS
--This function queries the distinct list of chemical substances which appear in the Drugs table 
--(the chemical substance is listed in the CHEMICAL_SUBSTANCE_BNF_DESCR column) 
RETURN SELECT  DISTINCT CHEMICAL_SUBSTANCE_BNF_DESCR AS Chemical_Substances FROM DRUGS;
GO

SELECT * FROM DBO.Get_Chemicals();
 GO

--TASK 2.5
CREATE OR ALTER PROCEDURE SP_Total_Prescriptions
AS
BEGIN
--This Procedure returns the number of prescriptions Grouped by 
-- chapter code BNF_CHAPTER_PLUS_CODE, 
--along with the average cost, minimum and maximum prescription costs for that chapter code   
--the BNF_CODE of drugs JOINED with BNF_CODE of Prescriptions table
--To show BNF_CHAPTER_PLUS_CODE(BNF_CODE description) 
	SELECT  A.BNF_CHAPTER_PLUS_CODE, 	
	COUNT(B.PRESCRIPTION_CODE) AS Total_Prescriptions,
	 AVG(B.ACTUAL_COST) as Average_cost, 
	 MIN(B.ACTUAL_COST) as  Minimum_Cost, MAX(B.ACTUAL_COST)  as Maximum_Cost	 
	 FROM DRUGS A INNER JOIN PRESCRIPTIONS B  ON A.BNF_CODE = B.BNF_CODE 
	 GROUP BY   A.BNF_CHAPTER_PLUS_CODE ORDER BY   A.BNF_CHAPTER_PLUS_CODE;
 END;
GO

 EXEC SP_Total_Prescriptions;
GO

 --TASK 2.6
CREATE OR ALTER PROCEDURE SP_Prescriptions_Cost_Above4k
AS
-- This Procedure returns that returns the most expensive prescription 
--with  Actual Cost more than £4000 prescribed by each practice and 
--with Practice name sorted in descending order by prescription cost  
BEGIN 
	SELECT   A.PRACTICE_CODE, B.PRACTICE_NAME, 
	MAX(A.ACTUAL_COST) as EXPENSIVE_PRESCRIPTIONS 
	FROM  Prescriptions A INNER JOIN Medical_Practice B 
	ON A.PRACTICE_CODE=B.PRACTICE_CODE  
	GROUP BY  A.PRACTICE_CODE ,  B.PRACTICE_NAME 
	HAVING MAX(A.ACTUAL_COST) > 4000  
	ORDER BY MAX(A.ACTUAL_COST) DESC ;
END;
 GO

EXEC SP_Prescriptions_Cost_Above4k;
GO

--Task 2.7 Additional 7 queries are implemented
-- Task2.7.1
 --Query to Return the List of Practices that used a specific Chemical Substance
 --eg: Sodium/Magnesium/Sodium chloride 
 --(Chemical names Referenced to CHEMICAL_SUBSTANCE_BNF_DESCR of Drugs Table) 
--Implemented this using a Two User Defined Functions. 
--1) LIKE_EXPR and 2) Prescription_With_Chemical
CREATE OR ALTER FUNCTION LIKE_EXPR(@STR AS NVARCHAR(100))
 RETURNS  NVARCHAR(100)
AS
--LIKE_EXPR will return the given nvarchar string enclosed  with %(percentage) symbol. 
--I am using this function for LIKE operators to work on Strings
BEGIN
	RETURN ('%'+@STR+'%')
END;
GO

--TESTING LIKE_EXPR
SELECT DBO.LIKE_EXPR('MAG');
GO

--Following Table-valued Function Prescription_With_Chemical Stored Procedure, 
--Returns the PRACTICE_CODE, PRACTICE_NAME and specific  
-- CHEMICAL SUBSTANCES that exist in the Prescribed Drugs
--Implemented using Common Table Expression, Joins, System-functions (Count) and User defined functions
 CREATE OR ALTER FUNCTION Prescription_With_Chemical(@Chemical as nvarchar(100))
 RETURNS TABLE AS 
 RETURN
  (SELECT DISTINCT M.PRACTICE_CODE, M.PRACTICE_NAME,
  D.CHEMICAL_SUBSTANCE_BNF_DESCR FROM  Medical_Practice M
  INNER JOIN Prescriptions P on M.PRACTICE_CODE= P.PRACTICE_CODE 
  INNER JOIN  Drugs D ON D.BNF_CODE = P.BNF_CODE WHERE D.BNF_CODE 
  IN ( SELECT  BNF_CODE   FROM DRUGS 
  WHERE  CHEMICAL_SUBSTANCE_BNF_DESCR 
  LIKE ( SELECT DBO.LIKE_EXPR(@Chemical))  ));
 GO
  --Select Query for Task 2.7.1
  Select * from dbo. Prescription_With_Chemical('magnesium'); 
  Select * from dbo. Prescription_With_Chemical('Sodium');  
  Select * from dbo. Prescription_With_Chemical('hydrogen peroxide');
 GO

   Select * from Drugs;
 GO

-- Task2.7.2  --Following Table-valued Function Prescribed_Chemical_Count
 --Returns the Number of times a specific Chemical Substance used by each Medical_Practice centers  in their prescriptions. 
 --(Chemical names Refers to CHEMICAL_SUBSTANCE_BNF_DESCR of Drugs Table) 
 --Implemented using Common Table Expression, Joins, System-functions (Count) and Uer defined function LIKE_EXPR
CREATE OR ALTER FUNCTION Prescribed_Chemical_Count(@Chemical as nvarchar(100))
RETURNS TABLE AS 
RETURN
(
 WITH Chemical (BNF_CODE)
  as 
  ( SELECT  BNF_CODE  FROM DRUGS 
  WHERE  CHEMICAL_SUBSTANCE_BNF_DESCR  
  LIKE  ( SELECT DBO.LIKE_EXPR(@Chemical)) )
 SELECT DISTINCT M.PRACTICE_CODE, M.PRACTICE_NAME,
  D.BNF_CODE,  D.CHEMICAL_SUBSTANCE_BNF_DESCR, 
  count( D.CHEMICAL_SUBSTANCE_BNF_DESCR) Count_Chemical_Usage 
  FROM  Medical_Practice M
  INNER JOIN Prescriptions P on M.PRACTICE_CODE= P.PRACTICE_CODE 
  INNER JOIN  Drugs D ON D.BNF_CODE = P.BNF_CODE 
  GROUP BY   M.PRACTICE_CODE, M.PRACTICE_NAME, 
  D.BNF_CODE,  D.CHEMICAL_SUBSTANCE_BNF_DESCR 
  HAVING D.BNF_CODE
  IN (SELECT  BNF_CODE FROM Chemical)
  );
GO
  --Select Query for Task 2.7.2
  SELECT * FROM DBO.Prescribed_Chemical_Count('latanoprost');
  SELECT * FROM DBO.Prescribed_Chemical_Count('sodium');
  SELECT * FROM DBO.Prescribed_Chemical_Count('magnesium');

 GO
  SELECT * FROM DBO.Prescribed_Chemical_Count('magnesium');
   Select * from dbo. Prescription_With_Chemical('Sodium');
  Select * from dbo. Prescription_With_Chemical('hydrogen peroxide');
  
 GO
 -- Task 2.7.3  
 ---Following Stored procedures is used to show the Name and Address specifications of 
 -- All or Specific Medical Practice centers from Medical_Practice table.  
 --Here, address columns are composed of a single column using the System function IsNull().
CREATE OR ALTER PROCEDURE PRACTICECENTRE_LOCATION
@ID AS NVARCHAR(50) = NULL
AS
BEGIN
IF (@ID IS NULL)
	BEGIN
		SELECT Practice_Code, PRACTICE_NAME as Medical_Practice_Centre, 
		ISNULL(Address_1,'') + ', ' +ISNULL(Address_2,'')+ ', ' +ISNULL(Address_3,'')+ ', ' +
		ISNULL(Address_4,'')+ ', ' +ISNULL(Postcode,'') AS Address_Location
		FROM Medical_Practice;
	END;
ELSE
	BEGIN
		SELECT Practice_Code, PRACTICE_NAME as Medical_Practice_Centre, 
		ISNULL(Address_1,'')+ ', ' +ISNULL(Address_2,'')+ ', ' +ISNULL(Address_3,'')+ ', ' + 
		ISNULL(Address_4,'')+ ', ' +ISNULL(Postcode,'') AS Address_Location
		FROM Medical_Practice WHERE PRACTICE_CODE = @ID;		
	END;
END;
GO

EXEC PRACTICECENTRE_LOCATION @ID='P82001';
 GO

EXEC PRACTICECENTRE_LOCATION ;
GO
-- Task 2.7.4 
--Following Stored procedures uses the Rank() over and Joins to Compute the Rank of 
--Practice Centers with Prescription having Actual_cost between100 and 1000
CREATE OR ALTER PROCEDURE PR_RANK_100_1000
AS
SELECT   A.PRACTICE_CODE, B.PRACTICE_NAME,
A.PRESCRIPTION_CODE, A.ACTUAL_COST,
RANK() OVER (ORDER BY A.ACTUAL_COST DESC) AS Rank
FROM  Prescriptions A INNER JOIN Medical_Practice B
ON A.PRACTICE_CODE=B.PRACTICE_CODE 
WHERE A.ACTUAL_COST BETWEEN 100 AND 1000;
GO

EXEC PR_RANK_100_1000;
 GO


-- Task 2.7.5 --Following Query Ranks the Practice Centers with their Prescription's Actual_cost more than 4000
--in the Ascending order of Practice Center names
--Query uses the Rank() over and Joins to Compute the Rank
WITH PR_HIGH_COST (PracticeCode, PracticeName,PrescriptionNum, ActualCost, Precription_Rank)
AS
(
SELECT   A.PRACTICE_CODE AS PracticeCode, B.PRACTICE_NAME as PracticeName,
A.PRESCRIPTION_CODE AS PrescriptionNum , 
MAX(A.ACTUAL_COST) as ActualCost,
RANK() OVER (ORDER BY A.ACTUAL_COST DESC) AS Precription_Rank
FROM  Prescriptions A INNER JOIN Medical_Practice B
ON A.PRACTICE_CODE=B.PRACTICE_CODE 
GROUP BY  A.PRACTICE_CODE ,  B.PRACTICE_NAME,A.PRESCRIPTION_CODE, ACTUAL_COST
HAVING MAX(A.ACTUAL_COST) > 4000
)
Select * FROM PR_HIGH_COST   ;
 GO



-- Task 2.7.6
--Following Stored Procedure is used to --Find the Count of Particular Type of Drug/Medicines Description Such as
--Capsules, Cream, Ointment, Suppositories, Tablets, etc.,
--Eg: Total SUSPENSION  Type Drugs are 106
--Total CREAM  Type Drugs are 221
CREATE OR ALTER PROCEDURE Get_DrugTypeCount
@MT AS NVARCHAR(150)
AS
BEGIN
DECLARE @VAR AS INT;
SET @VAR =(SELECT  count(BNF_DESCRIPTION)  AS MEDICINETYPE_COUNT FROM DRUGS 
WHERE BNF_DESCRIPTION LIKE (SELECT DBO.LIKE_EXPR(@MT)));
PRINT('Total '+ upper(@MT)+'  Type Drugs are ' +cast( @VAR as nvarchar));
END;
GO

EXEC Get_DrugTypeCount @mt= 'ointment';
GO

EXEC Get_DrugTypeCount @mt= 'powder';
GO

EXEC Get_DrugTypeCount @mt= 'solution';
 
 GO


-- Task 2.7.7 --Following Stored Procedure uses IIF system function to 
--Find the Stock Count of most common Type of Drug/Medicines Descrition Such as 
--Tablets, Capsules, Sachets, Powder, Liquids, Suspensions, Solutions, Tube,
--Ointment, Cream, Suppositories, etc.,
 CREATE OR ALTER PROCEDURE GetAllDrugTypeStock
AS
BEGIN
  SELECT 
    SUM(IIF(BNF_DESCRIPTION LIKE '%tablet%', 1, 0) ) AS Tablet,
	SUM(IIF(BNF_DESCRIPTION LIKE '%chewable%' , 1, 0)) AS Chewable,
    SUM(IIF(BNF_DESCRIPTION LIKE '%capsule%' , 1, 0)) AS Capsule,
	SUM(IIF(BNF_DESCRIPTION LIKE '%drops%' , 1, 0)) AS Drops,
    SUM(IIF(BNF_DESCRIPTION LIKE '%sachet%' , 1, 0)) AS Sachet,
    SUM(IIF(BNF_DESCRIPTION LIKE '%powder%', 1 , 0)) AS Powder,
    SUM(IIF(BNF_DESCRIPTION LIKE '%liquid%' , 1, 0)) AS Liquid,
    SUM(IIF(BNF_DESCRIPTION LIKE '%suspension%' ,1 ,0)) AS Suspension,
    SUM(IIF(BNF_DESCRIPTION LIKE '%solution%' , 1,0)) AS Solution,
    SUM(IIF(BNF_DESCRIPTION LIKE '%tube%' , 1, 0)) AS Tube,
    SUM(IIF(BNF_DESCRIPTION LIKE '%ointment%', 1,0)) AS Ointment,
    SUM(IIF(BNF_DESCRIPTION LIKE '%cream%', 1,0)) AS Cream,
    SUM(IIF(BNF_DESCRIPTION LIKE '%suppositor%', 1,0)) AS Suppository,
	SUM(IIF(BNF_DESCRIPTION LIKE '%enema%' , 1, 0)) AS Enema,
	SUM(IIF(BNF_DESCRIPTION LIKE '%injection%' , 1, 0)) AS Injection,
	SUM(IIF(BNF_DESCRIPTION LIKE '%gel%' , 1, 0)) AS Gel,
	SUM(IIF(BNF_DESCRIPTION LIKE '%oil%' , 1, 0)) AS Oil,
	SUM(IIF(BNF_DESCRIPTION LIKE '%foam%' , 1, 0)) AS Foam,
	SUM(IIF(BNF_DESCRIPTION LIKE '%tape%' , 1, 0)) AS Tape,
	SUM(IIF(BNF_DESCRIPTION LIKE '%shampoo%' , 1, 0)) AS Shampoo
  FROM Drugs
END;
GO

EXEC GetAllDrugTypeStock;
 GO

