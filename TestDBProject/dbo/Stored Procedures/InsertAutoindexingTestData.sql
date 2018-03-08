CREATE PROCEDURE [dbo].[InsertAutoindexingTestData]
AS 
  BEGIN 
     
	--truncate table AD
	--truncate table PATTERNMASTER
	--truncate table PATTERNDETAILRA
	--truncate table PATTERNSTATISTICS
	--truncate table CREATIVEMASTER
	--truncate table CREATIVEDETAILRA

	Insert into [CREATIVEMASTERSTAGING] values( NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, getdate(), NULL, 1)	
	Insert into [CREATIVEMASTERSTAGING] values( NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, getdate(), NULL, 3)	
	Insert into [CREATIVEMASTERSTAGING] values( NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, getdate(), NULL, 5)
	Insert into [CREATIVEMASTERSTAGING] values( NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, getdate(), NULL, 6)
	Insert into [CREATIVEMASTERSTAGING] values( NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, getdate(), NULL, 7)
	Insert into [CREATIVEMASTERSTAGING] values( NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, getdate(), NULL, 8)
	Insert into [CREATIVEMASTERSTAGING] values( NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, getdate(), NULL, 9)
	Insert into [CREATIVEMASTERSTAGING] values( NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, getdate(), NULL, 10)
	--Insert into [CREATIVEMASTERSTAGING] values( NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, getdate(), NULL, 8)
	--Insert into [CREATIVEMASTERSTAGING] values( NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, getdate(), NULL, 9)
	--Insert into [CREATIVEMASTERSTAGING] values( NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, getdate(), NULL, 10)


	Insert into [CREATIVEDETAILSRASTAGING] values(1, 'wav', 'D:\MCAP_Assets\Radio\', '6.mp3', 100)
	Insert into [CREATIVEDETAILSRASTAGING] values(2, 'wav', 'D:\MCAP_Assets\Radio\', '6.mp3', 10000)
	Insert into [CREATIVEDETAILSRASTAGING] values(3, 'wav', 'D:\MCAP_Assets\Radio\', '6.mp3', 1000)
	Insert into [CREATIVEDETAILSRASTAGING] values(4, 'wav', 'D:\MCAP_Assets\Radio\', '6.mp3', 300)
	Insert into [CREATIVEDETAILSRASTAGING] values(5, 'wav', 'D:\MCAP_Assets\Radio\', '6.mp3', 500)
	Insert into [CREATIVEDETAILSRASTAGING] values(6, 'wav', 'D:\MCAP_Assets\Radio\', '6.mp3', 1000)
	Insert into [CREATIVEDETAILSRASTAGING] values(7, 'wav', 'D:\MCAP_Assets\Radio\', '6.mp3', 300)
	Insert into [CREATIVEDETAILSRASTAGING] values(8, 'wav', 'D:\MCAP_Assets\Radio\', '6.mp3', 500)

	--Insert into [CREATIVEDETAILSRASTAGING] values(6, 'wav', 'D:\MCAP_Assets\Radio\', '6.mp3', 100)
	--Insert into [CREATIVEDETAILSRASTAGING] values(7, 'wav', 'D:\MCAP_Assets\Radio\', '6.mp3', 10000)
	--Insert into [CREATIVEDETAILSRASTAGING] values(8, 'wav', 'D:\MCAP_Assets\Radio\', '6.mp3', 1000)
	--Insert into [CREATIVEDETAILSRASTAGING] values(9, 'wav', 'D:\MCAP_Assets\Radio\', '6.mp3', 300)
	--Insert into [CREATIVEDETAILSRASTAGING] values(10, 'wav', 'D:\MCAP_Assets\Radio\', '6.mp3', 500)


	Update [PATTERNMASTERSTAGING] set CreativeStagingID = 1, AutoIndexing = 1 where patternmasterstagingid = 1
	Update [PATTERNMASTERSTAGING] set CreativeStagingID = 2, AutoIndexing = 1 where patternmasterstagingid = 2
	Update [PATTERNMASTERSTAGING] set CreativeStagingID = 3, AutoIndexing = 0 where patternmasterstagingid = 3
	Update [PATTERNMASTERSTAGING] set CreativeStagingID = 4, AutoIndexing = 0 where patternmasterstagingid = 4
	Update [PATTERNMASTERSTAGING] set CreativeStagingID = 5, AutoIndexing = 0 where patternmasterstagingid = 5
	
	Update [PATTERNMASTERSTAGING] set CreativeStagingID = 6, AutoIndexing = 0 where patternmasterstagingid = 6
	Update [PATTERNMASTERSTAGING] set CreativeStagingID = 7, AutoIndexing = 0 where patternmasterstagingid = 7
	Update [PATTERNMASTERSTAGING] set CreativeStagingID = 8, AutoIndexing = 0 where patternmasterstagingid = 8
	

	END