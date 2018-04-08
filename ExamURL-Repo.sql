/**
		https://www.mssqltips.com/sqlservertip/2885/study-materials-for-implementing-a-data-warehouse-with-microsoft-sql-server-2012-exam-70463/
**/

--List all major topics
SELECT 
		MajorTopicTitle,
		MajorTopicID
FROM [ImplementingDataWarehouseExamTopicURLs].dbo.MajorTopic


-- List all subtopics for all major topics
-- commented lines show some optional code
SELECT 
		m.MajorTopicTitle,
		s.SubTopicTitle,
		s.MajorTopicID,
		s.SubTopicID
FROM [ImplementingDataWarehouseExamTopicURLs].dbo.MajorTopic m
		INNER JOIN [ImplementingDataWarehouseExamTopicURLs].dbo.SubTopic s
			ON m.MajorTopicID = s.MajorTopicID
--WHERE m.MajorTopicID = 2 or m.MajorTopicID = 4
--GROUP BY m.MajorTopicTitle
--ORDER BY m.MajorTopicID, s.SubTopicID

-- List all URLs and their titles
SELECT Title, URL
FROM ImplementingDataWarehouseExamTopicURLs.dbo.URL


-- WebSites for all URls, including dupes
SELECT [MajorTopicID], [SubTopicID], Title, URL,SUBSTRING(URL,CHARINDEX('//',URL)+2,CHARINDEX('/',URL,CHARINDEX('//',URL)+2)-(CHARINDEX('//',URL)+2)) WebSite
FROM ImplementingDataWarehouseExamTopicURLs.dbo.URL
--WHERE CHARINDEX('//',URL) <> 6

-- WebSites for distinct URLs
SELECT DISTINCT URL, SUBSTRING(URL,CHARINDEX('//',URL)+2,CHARINDEX('/',URL,CHARINDEX('//',URL)+2)-(CHARINDEX('//',URL)+2)) WebSite
FROM ImplementingDataWarehouseExamTopicURLs.dbo.URL



-- Count of distinct URL references by Website
-- 36 Websites
SELECT WebSite, Count(*) CountOfDistinctURLsForWebSite
FROM
(
SELECT DISTINCT URL, SUBSTRING(URL,CHARINDEX('//',URL)+2,CHARINDEX('/',URL,CHARINDEX('//',URL)+2)-(CHARINDEX('//',URL)+2)) WebSite
FROM ImplementingDataWarehouseExamTopicURLs.dbo.URL
) distinct_URLs_WebSites
GROUP BY WebSite
ORDER BY COUNT(*) DESC

-- Websites with 2 or more distinct references
SELECT WebSite, Count(*) CountOfDistinctURLsFromWebsite
FROM
(
SELECT DISTINCT URL, SUBSTRING(URL,CHARINDEX('//',URL)+2,CHARINDEX('/',URL,CHARINDEX('//',URL)+2)-(CHARINDEX('//',URL)+2)) WebSite
FROM ImplementingDataWarehouseExamTopicURLs.dbo.URL
) distinct_URLs_WebSites
GROUP BY WebSite
HAVING COUNT(*) >= 2
ORDER BY COUNT(*) DESC


-- List all URLs for all major topics and their subtopics
SELECT 
		m.MajorTopicTitle,
		s.SubTopicTitle,
		u.MajorTopicID,
		u.SubTopicID,
		u.Title,
		u.URL
FROM [ImplementingDataWarehouseExamTopicURLs].dbo.MajorTopic m
		INNER JOIN [ImplementingDataWarehouseExamTopicURLs].dbo.SubTopic s
			ON m.MajorTopicID = s.MajorTopicID
			INNER JOIN [ImplementingDataWarehouseExamTopicURLs].dbo.URL u
				ON s.SubTopicID = u.SubTopicID AND s.MajorTopicID = u.MajorTopicID

-- Count of URLs by subtopic within major topic
SELECT 
		m.MajorTopicTitle,
		s.SubTopicTitle,
		u.MajorTopicID,
		u.SubTopicID,
		--u.Title,
		COUNT(u.URL) URLCount
FROM [ImplementingDataWarehouseExamTopicURLs].dbo.MajorTopic m
		INNER JOIN [ImplementingDataWarehouseExamTopicURLs].dbo.SubTopic s
			ON m.MajorTopicID = s.MajorTopicID
			INNER JOIN [ImplementingDataWarehouseExamTopicURLs].dbo.URL u
				ON s.SubTopicID = u.SubTopicID AND s.MajorTopicID = u.MajorTopicID
GROUP BY 
		m.MajorTopicTitle,
		s.SubTopicTitle,
		u.MajorTopicID,
		u.SubTopicID

-- List URLs for a major topic and subtopic pair
-- with pair values in the WHERE clause 
SELECT 
		m.MajorTopicTitle,
		s.SubTopicTitle,
		--u.MajorTopicID,
		--u.SubTopicID,
		u.Title,
		u.URL
FROM [ImplementingDataWarehouseExamTopicURLs].dbo.MajorTopic m
		INNER JOIN [ImplementingDataWarehouseExamTopicURLs].dbo.SubTopic s
			ON m.MajorTopicID = s.MajorTopicID
			INNER JOIN [ImplementingDataWarehouseExamTopicURLs].dbo.URL u
				ON s.SubTopicID = u.SubTopicID AND s.MajorTopicID = u.MajorTopicID
WHERE u.MajorTopicID = 4 AND u.SubTopicID = 4

-- Find duplicate URLs
SELECT 
		u.URL,
		COUNT(*)
FROM [ImplementingDataWarehouseExamTopicURLs].dbo.MajorTopic m
		INNER JOIN [ImplementingDataWarehouseExamTopicURLs].dbo.SubTopic s
			ON m.MajorTopicID = s.MajorTopicID
			INNER JOIN [ImplementingDataWarehouseExamTopicURLs].dbo.URL u
				ON s.SubTopicID = u.SubTopicID AND s.MajorTopicID = u.MajorTopicID
GROUP BY u.URL
HAVING COUNT(*)>1


-- Duplicate URLs with Titles
SELECT 
		u.Title,
		u.URL,
		COUNT(*) NumberOfRepeats
FROM [ImplementingDataWarehouseExamTopicURLs].dbo.MajorTopic m
		INNER JOIN [ImplementingDataWarehouseExamTopicURLs].dbo.SubTopic s
			ON m.MajorTopicID = s.MajorTopicID
			INNER JOIN [ImplementingDataWarehouseExamTopicURLs].dbo.URL u
				ON s.SubTopicID = u.SubTopicID AND s.MajorTopicID = u.MajorTopicID
GROUP BY u.Title, u.URL
HAVING COUNT(*)>1
ORDER BY COUNT(*) DESC

-- Listing of duplicate URLs in the database with
-- extra info to help identify and manage duplicates
SELECT *
FROM
(
SELECT 
		u.URL Duped_URL,
		COUNT(*) Duped_Count
FROM [ImplementingDataWarehouseExamTopicURLs].dbo.MajorTopic m
		INNER JOIN [ImplementingDataWarehouseExamTopicURLs].dbo.SubTopic s
			ON m.MajorTopicID = s.MajorTopicID
			INNER JOIN [ImplementingDataWarehouseExamTopicURLs].dbo.URL u
				ON s.SubTopicID = u.SubTopicID AND s.MajorTopicID = u.MajorTopicID
GROUP BY u.URL
HAVING COUNT(*)>1
) dupeURLs
	LEFT JOIN
(
SELECT 
		m.MajorTopicTitle,
		s.SubTopicTitle,
		u.MajorTopicID,
		u.SubTopicID,
		u.Title,
		u.URL
FROM [ImplementingDataWarehouseExamTopicURLs].dbo.MajorTopic m
		INNER JOIN [ImplementingDataWarehouseExamTopicURLs].dbo.SubTopic s
			ON m.MajorTopicID = s.MajorTopicID
			INNER JOIN [ImplementingDataWarehouseExamTopicURLs].dbo.URL u
				ON s.SubTopicID = u.SubTopicID AND s.MajorTopicID = u.MajorTopicID
) allRows
	ON allRows.URL = dupeURLs.Duped_URL


-- List Duped_Urls with Title, Major Topic, and Subtopic
SELECT *
FROM
(
SELECT 
		u.URL Duped_URL,
		COUNT(*) Duped_Count
FROM [ImplementingDataWarehouseExamTopicURLs].dbo.MajorTopic m
		INNER JOIN [ImplementingDataWarehouseExamTopicURLs].dbo.SubTopic s
			ON m.MajorTopicID = s.MajorTopicID
			INNER JOIN [ImplementingDataWarehouseExamTopicURLs].dbo.URL u
				ON s.SubTopicID = u.SubTopicID AND s.MajorTopicID = u.MajorTopicID
GROUP BY u.URL
HAVING COUNT(*)>1
) dupeURLs
	LEFT JOIN
(
SELECT 
		m.MajorTopicTitle,
		s.SubTopicTitle,
		u.MajorTopicID,
		u.SubTopicID,
		u.Title,
		u.URL
FROM [ImplementingDataWarehouseExamTopicURLs].dbo.MajorTopic m
		INNER JOIN [ImplementingDataWarehouseExamTopicURLs].dbo.SubTopic s
			ON m.MajorTopicID = s.MajorTopicID
			INNER JOIN [ImplementingDataWarehouseExamTopicURLs].dbo.URL u
				ON s.SubTopicID = u.SubTopicID AND s.MajorTopicID = u.MajorTopicID
) allRows
	ON allRows.URL = dupeURLs.Duped_URL

-- Code samples from the article to insert and delete URL references
-- See the tip for instructions on how to assign values to
-- MajorTopicIDValue, SubTopicIDValue, URL, and Title

INSERT [ImplementingDataWarehouseExamTopicURLs].dbo.URL
	(	MajorTopicID,
		SubTopicID,
		Title,
		URL
	)
VALUES
	(
		MajorTopicIDValue,
		SubTopicIDValue,
		'Title that you want for your new URL',
		'URLLocatorValue for your new URL'
	)

DELETE 
FROM [ImplementingDataWarehouseExamTopicURLs].dbo.URL 
WHERE MajorTopicID = MajorTopicIDValue AND SubTopicID = SubTopicIDValue 
	  			   AND Title = 'Title the URL reference you want to delete'

