USE [master]
GO
/****** Object:  Database [u_stodolki]    Script Date: 16.02.2025 23:41:40 ******/
CREATE DATABASE [u_stodolki]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'u_stodolki', FILENAME = N'/var/opt/mssql/data/u_stodolki.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'u_stodolki_log', FILENAME = N'/var/opt/mssql/data/u_stodolki_log.ldf' , SIZE = 66048KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [u_stodolki] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [u_stodolki].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [u_stodolki] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [u_stodolki] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [u_stodolki] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [u_stodolki] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [u_stodolki] SET ARITHABORT OFF 
GO
ALTER DATABASE [u_stodolki] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [u_stodolki] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [u_stodolki] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [u_stodolki] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [u_stodolki] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [u_stodolki] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [u_stodolki] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [u_stodolki] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [u_stodolki] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [u_stodolki] SET  ENABLE_BROKER 
GO
ALTER DATABASE [u_stodolki] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [u_stodolki] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [u_stodolki] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [u_stodolki] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [u_stodolki] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [u_stodolki] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [u_stodolki] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [u_stodolki] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [u_stodolki] SET  MULTI_USER 
GO
ALTER DATABASE [u_stodolki] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [u_stodolki] SET DB_CHAINING OFF 
GO
ALTER DATABASE [u_stodolki] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [u_stodolki] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [u_stodolki] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [u_stodolki] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [u_stodolki] SET QUERY_STORE = OFF
GO
USE [u_stodolki]
GO
/****** Object:  UserDefinedFunction [dbo].[CalculateCartValue]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[CalculateCartValue] (@CartID INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @TotalValue DECIMAL(10, 2) = 0; -- Domyślnie 0 w przypadku braku wyników

    SELECT @TotalValue = SUM(ci.Quantity * p.Price)
    FROM CartItems ci
    JOIN Products p ON ci.ProductID = p.ProductID
    WHERE ci.CartID = @CartID;

    -- Jeśli suma jest NULL, ustawiamy wartość na 0
    IF @TotalValue IS NULL
    BEGIN
        SET @TotalValue = 0;
    END

    RETURN @TotalValue;
END;

GO
/****** Object:  UserDefinedFunction [dbo].[CanAccessCourseMaterials]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[CanAccessCourseMaterials] (@UserID INT, @CourseID INT)
RETURNS BIT
AS
BEGIN
    DECLARE @HasAccess BIT = 0;
    IF EXISTS (
        SELECT 1 
        FROM Enrollments
        WHERE UserID = @UserID AND CourseID = @CourseID
    )
        SET @HasAccess = 1;

    RETURN @HasAccess;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[CanUserAccessCourseMaterials]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[CanUserAccessCourseMaterials] (@UserID INT, @CourseID INT)
RETURNS BIT
AS
BEGIN
    DECLARE @HasAccess BIT = 0;
    IF EXISTS (
        SELECT 1 
        FROM Enrollments
        WHERE UserID = @UserID AND CourseID = @CourseID
    )
        SET @HasAccess = 1;

    RETURN @HasAccess;
END;

GO
/****** Object:  UserDefinedFunction [dbo].[GetTotalOrderValue]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetTotalOrderValue] (@OrderID INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @TotalValue DECIMAL(10, 2);

    SELECT @TotalValue = SUM(oi.Quantity * p.Price)
    FROM OrderItems oi
    JOIN Products p ON oi.ProductID = p.ProductID
    WHERE oi.OrderID = @OrderID;

    RETURN @TotalValue;
END;

GO
/****** Object:  Table [dbo].[Webinars]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Webinars](
	[WebinarID] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](255) NOT NULL,
	[InstructorID] [int] NOT NULL,
	[Description] [nvarchar](1000) NULL,
	[DateTime] [datetime] NOT NULL,
	[IsFree] [bit] NOT NULL,
	[AccessLink] [nvarchar](500) NULL,
	[Duration] [int] NOT NULL,
	[VideoLink] [nvarchar](500) NULL,
	[Language] [nvarchar](50) NOT NULL,
	[IsTranslated] [bit] NOT NULL,
	[TranslatorFirstName] [nvarchar](100) NULL,
	[TranslatorLastName] [nvarchar](100) NULL,
	[IsDeleted] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[WebinarID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [unique_title] UNIQUE NONCLUSTERED 
(
	[Title] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[ViewWebinars]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ViewWebinars]()
RETURNS TABLE
AS
RETURN
    SELECT WebinarID, Title, DateTime, IsFree
    FROM Webinars
    WHERE IsDeleted = 0;

GO
/****** Object:  Table [dbo].[Enrollments]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Enrollments](
	[EnrollmentID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[CourseID] [int] NULL,
	[WebinarID] [int] NULL,
	[StudyID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[EnrollmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [unique_user_course] UNIQUE NONCLUSTERED 
(
	[UserID] ASC,
	[CourseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [unique_user_webinar] UNIQUE NONCLUSTERED 
(
	[UserID] ASC,
	[WebinarID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Courses]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Courses](
	[CourseID] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[IsHybrid] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CourseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Studies]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Studies](
	[StudyID] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](100) NOT NULL,
	[Program] [text] NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[NumberOfSpots] [int] NOT NULL,
	[EntryFee] [decimal](10, 2) NOT NULL,
	[Language] [nvarchar](50) NOT NULL,
	[Description] [text] NULL,
PRIMARY KEY CLUSTERED 
(
	[StudyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [unique_studies_title] UNIQUE NONCLUSTERED 
(
	[Title] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[AttendanceReport]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AttendanceReport] AS
SELECT
    'Webinar' AS EventType,
    W.Title AS EventTitle,
    COUNT(E.EnrollmentID) AS AttendanceCount,
    W.DateTime AS EventDate
FROM
    Webinars W
LEFT JOIN
    Enrollments E
    ON W.WebinarID = E.WebinarID
WHERE
    W.IsDeleted = 0
    AND W.DateTime < GETDATE() -- Wydarzenia zakończone
GROUP BY
    W.Title, W.DateTime

UNION ALL

SELECT
    'Course' AS EventType,
    C.Title AS EventTitle,
    COUNT(E.EnrollmentID) AS AttendanceCount,
    C.EndDate AS EventDate
FROM
    Courses C
LEFT JOIN
    Enrollments E
    ON C.CourseID = E.CourseID
WHERE
    C.EndDate < GETDATE() -- Kursy zakończone
GROUP BY
    C.Title, C.EndDate

UNION ALL

SELECT
    'Study' AS EventType,
    S.Title AS EventTitle,
    COUNT(E.EnrollmentID) AS AttendanceCount,
    S.EndDate AS EventDate
FROM
    Studies S
LEFT JOIN
    Enrollments E
    ON S.StudyID = E.StudyID
WHERE
    S.EndDate < GETDATE() -- Studia zakończone
GROUP BY
    S.Title, S.EndDate;



GO
/****** Object:  Table [dbo].[Products]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Products](
	[ProductID] [int] IDENTITY(1,1) NOT NULL,
	[ProductType] [varchar](20) NOT NULL,
	[Price] [decimal](10, 2) NOT NULL,
	[CurrencyCode] [varchar](10) NOT NULL,
	[WebinarID] [int] NULL,
	[CourseID] [int] NULL,
	[StudyID] [int] NULL,
	[SessionID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Payments]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Payments](
	[UserAccountID] [int] NOT NULL,
	[CurrencyID] [int] NOT NULL,
	[PaymentStatus] [varchar](20) NOT NULL,
	[PaymentDate] [datetime] NOT NULL,
	[PaymentID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_Payments] PRIMARY KEY CLUSTERED 
(
	[PaymentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Orders]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Orders](
	[OrderID] [int] IDENTITY(1,1) NOT NULL,
	[UserAccountID] [int] NOT NULL,
	[OrderDate] [datetime] NOT NULL,
	[OrderStatus] [varchar](20) NOT NULL,
	[OrderTotal] [decimal](10, 2) NOT NULL,
	[PaymentID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[FinancialReports]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[FinancialReports] AS
SELECT
    CASE 
        WHEN p.WebinarID IS NOT NULL THEN 'Webinar'
        WHEN p.CourseID IS NOT NULL THEN 'Course'
        WHEN p.StudyID IS NOT NULL THEN 'Study'
        ELSE 'Other'
    END AS ProductCategory,
    COALESCE(p.WebinarID, p.CourseID, p.StudyID) AS ProductReferenceID,
    SUM(o.OrderTotal) AS TotalRevenue,
    COUNT(o.OrderID) AS TotalOrders,
    MIN(o.OrderDate) AS FirstOrderDate,
    MAX(o.OrderDate) AS LastOrderDate
FROM 
    Orders o
JOIN Products p ON o.OrderID = p.ProductID
JOIN Payments pay ON o.PaymentID = pay.PaymentID
WHERE 
    pay.PaymentStatus = 'Completed'
GROUP BY 
    CASE 
        WHEN p.WebinarID IS NOT NULL THEN 'Webinar'
        WHEN p.CourseID IS NOT NULL THEN 'Course'
        WHEN p.StudyID IS NOT NULL THEN 'Study'
        ELSE 'Other'
    END,
    COALESCE(p.WebinarID, p.CourseID, p.StudyID);
GO
/****** Object:  Table [dbo].[UsersAccount]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UsersAccount](
	[UserAccountID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[Username] [varchar](50) NOT NULL,
	[PasswordHash] [varchar](255) NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UserAccountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [unique_username] UNIQUE NONCLUSTERED 
(
	[Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[DebtorsList]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DebtorsList] AS
SELECT
    ua.UserAccountID,
    ua.Username,
    ua.CreatedAt AS AccountCreationDate,
    o.OrderID,
    o.OrderDate,
    o.OrderTotal,
    p.PaymentStatus
FROM 
    UsersAccount ua
JOIN Orders o ON ua.UserAccountID = o.UserAccountID
LEFT JOIN Payments p ON o.PaymentID = p.PaymentID
WHERE 
    (p.PaymentStatus IS NULL OR p.PaymentStatus != 'Completed')
    AND o.OrderStatus != 'Cancelled';
GO
/****** Object:  Table [dbo].[Sessions]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sessions](
	[SessionID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[ScheduleID] [int] NOT NULL,
	[StudyID] [int] NOT NULL,
	[SessionDate] [datetime] NOT NULL,
	[SessionType] [varchar](20) NOT NULL,
	[Topic] [varchar](255) NOT NULL,
	[NumberOfSpots] [int] NOT NULL,
	[Notes] [text] NULL,
PRIMARY KEY CLUSTERED 
(
	[SessionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[EventEnrollmentReport]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[EventEnrollmentReport] AS
SELECT
    'Webinar' AS EventType,
    w.WebinarID AS EventID,
    w.Title AS EventTitle,
    w.DateTime AS EventDate,
    'Online' AS EventMode,
    COUNT(e.EnrollmentID) AS TotalEnrollments
FROM 
    Webinars w
LEFT JOIN Enrollments e ON w.WebinarID = e.WebinarID
WHERE 
    w.IsDeleted = 0 AND w.DateTime > GETDATE()
GROUP BY 
    w.WebinarID, w.Title, w.DateTime

UNION ALL

SELECT
    'Course' AS EventType,
    c.CourseID AS EventID,
    c.Title AS EventTitle,
    c.StartDate AS EventDate,
    CASE 
        WHEN c.IsHybrid = 1 THEN 'Hybrid'
        ELSE 'Stationary'
    END AS EventMode,
    COUNT(e.EnrollmentID) AS TotalEnrollments
FROM 
    Courses c
LEFT JOIN Enrollments e ON c.CourseID = e.CourseID
WHERE 
    c.StartDate > GETDATE()
GROUP BY 
    c.CourseID, c.Title, c.StartDate, c.IsHybrid

UNION ALL

SELECT
    'Study' AS EventType,
    s.StudyID AS EventID,
    s.Title AS EventTitle,
    s.StartDate AS EventDate,
    CASE 
        WHEN COUNT(DISTINCT sess.SessionType) = 1 AND MIN(sess.SessionType) = 'stationary' THEN 'Stationary'
        WHEN COUNT(DISTINCT sess.SessionType) = 1 AND MIN(sess.SessionType) = 'online' THEN 'Online'
        ELSE 'Hybrid'
    END AS EventMode,
    COUNT(e.EnrollmentID) AS TotalEnrollments
FROM 
    Studies s
LEFT JOIN Sessions sess ON s.StudyID = sess.StudyID
LEFT JOIN Enrollments e ON s.StudyID = e.StudyID
WHERE 
    s.StartDate > GETDATE()
GROUP BY 
    s.StudyID, s.Title, s.StartDate;
GO
/****** Object:  Table [dbo].[Users]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](100) NOT NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[EmailAddress] [nvarchar](150) NOT NULL,
	[Address] [nvarchar](255) NULL,
	[City] [nvarchar](100) NULL,
	[PostalCode] [nvarchar](8) NULL,
	[PhoneNumber] [nvarchar](15) NULL,
	[Role] [nvarchar](50) NOT NULL,
	[IsRegistered] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [unique_email] UNIQUE NONCLUSTERED 
(
	[EmailAddress] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[EmailAddress] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[BilocationReport]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[BilocationReport] AS
WITH FutureTrainings AS (
    SELECT 
        e.UserID,
        'Webinar' AS TrainingType,
        w.Title AS TrainingTitle,
        w.DateTime AS StartTime,
        DATEADD(MINUTE, w.Duration, w.DateTime) AS EndTime
    FROM Enrollments e
    JOIN Webinars w ON e.WebinarID = w.WebinarID
    WHERE w.DateTime > GETDATE() AND w.IsDeleted = 0

    UNION ALL

    SELECT 
        e.UserID,
        'Course' AS TrainingType,
        c.Title AS TrainingTitle,
        c.StartDate AS StartTime,
        c.EndDate AS EndTime
    FROM Enrollments e
    JOIN Courses c ON e.CourseID = c.CourseID
    WHERE c.StartDate > GETDATE()

    UNION ALL

    SELECT 
        e.UserID,
        'Study' AS TrainingType,
        s.Title AS TrainingTitle,
        s.StartDate AS StartTime,
        s.EndDate AS EndTime
    FROM Enrollments e
    JOIN Studies s ON e.StudyID = s.StudyID
    WHERE s.StartDate > GETDATE()
)
SELECT 
    u.FirstName,
    u.LastName,
    ft1.TrainingTitle AS Training1,
    ft1.TrainingType AS Training1Type,
    ft1.StartTime AS Training1Start,
    ft1.EndTime AS Training1End,
    ft2.TrainingTitle AS Training2,
    ft2.TrainingType AS Training2Type,
    ft2.StartTime AS Training2Start,
    ft2.EndTime AS Training2End
FROM 
    FutureTrainings ft1
JOIN FutureTrainings ft2 
    ON ft1.UserID = ft2.UserID
    AND ft1.StartTime < ft2.EndTime
    AND ft1.EndTime > ft2.StartTime
    AND ft1.TrainingTitle <> ft2.TrainingTitle
JOIN Users u ON ft1.UserID = u.UserID;
GO
/****** Object:  Table [dbo].[Attendance]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Attendance](
	[AttendanceID] [int] IDENTITY(1,1) NOT NULL,
	[EnrollmentID] [int] NOT NULL,
	[SessionDate] [datetime] NOT NULL,
	[IsPresent] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AttendanceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [unique_user_session] UNIQUE NONCLUSTERED 
(
	[EnrollmentID] ASC,
	[SessionDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[AttendanceList]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AttendanceList] AS
SELECT 
    'Webinar' AS TrainingType,
    w.Title AS TrainingTitle,
    a.SessionDate,
    CONCAT(u.FirstName, ' ', u.LastName) AS ParticipantName,
    a.IsPresent
FROM 
    Attendance a
JOIN Enrollments e ON a.EnrollmentID = e.EnrollmentID
JOIN Webinars w ON e.WebinarID = w.WebinarID
JOIN UsersAccount ua ON e.UserID = ua.UserID
JOIN Users u ON ua.UserID = u.UserID
WHERE 
    w.IsDeleted = 0

UNION ALL

SELECT 
    'Course' AS TrainingType,
    c.Title AS TrainingTitle,
    a.SessionDate,
    CONCAT(u.FirstName, ' ', u.LastName) AS ParticipantName,
    a.IsPresent
FROM 
    Attendance a
JOIN Enrollments e ON a.EnrollmentID = e.EnrollmentID
JOIN Courses c ON e.CourseID = c.CourseID
JOIN UsersAccount ua ON e.UserID = ua.UserID
JOIN Users u ON ua.UserID = u.UserID

UNION ALL

SELECT DISTINCT 
    'Study' AS TrainingType,
    s.Title AS TrainingTitle,
    a.SessionDate,
    CONCAT(u.FirstName, ' ', u.LastName) AS ParticipantName,
    a.IsPresent
FROM 
    Attendance a
JOIN Enrollments e ON a.EnrollmentID = e.EnrollmentID
JOIN Sessions sess ON sess.StudyID = e.StudyID AND sess.SessionDate = a.SessionDate
JOIN Studies s ON sess.StudyID = s.StudyID
JOIN UsersAccount ua ON e.UserID = ua.UserID
JOIN Users u ON ua.UserID = u.UserID;
GO
/****** Object:  Table [dbo].[CartItems]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CartItems](
	[CartItemID] [int] IDENTITY(1,1) NOT NULL,
	[CartID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CartItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Currency]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Currency](
	[CurrencyID] [int] IDENTITY(1,1) NOT NULL,
	[CurrencyName] [varchar](50) NULL,
	[CurrencyCode] [varchar](10) NOT NULL,
	[ExchangeRate] [decimal](10, 4) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CurrencyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [unique_currencycode] UNIQUE NONCLUSTERED 
(
	[CurrencyCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Diplomas]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Diplomas](
	[DiplomaID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[CourseID] [int] NOT NULL,
	[IssuedDate] [datetime] NOT NULL,
	[Address] [varchar](50) NOT NULL,
	[IsSent] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[DiplomaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Exams]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Exams](
	[ExamID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[StudyID] [int] NOT NULL,
	[ExamDate] [datetime] NOT NULL,
	[ExamScore] [decimal](3, 2) NOT NULL,
 CONSTRAINT [exams_pk] PRIMARY KEY CLUSTERED 
(
	[ExamID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Internships]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Internships](
	[InternshipID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[Status] [varchar](20) NOT NULL,
	[StudyProgramID] [int] NOT NULL,
	[Year] [int] NOT NULL,
	[Period] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[InternshipID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [unique_internship] UNIQUE NONCLUSTERED 
(
	[StudyProgramID] ASC,
	[Year] ASC,
	[Period] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Lecturers]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lecturers](
	[LecturerID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[CourseID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[LecturerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Modules]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Modules](
	[ModuleID] [int] IDENTITY(1,1) NOT NULL,
	[CourseID] [int] NOT NULL,
	[Title] [nvarchar](255) NOT NULL,
	[ModuleType] [nvarchar](50) NOT NULL,
	[Location] [nvarchar](255) NULL,
	[IsCompleted] [bit] NOT NULL,
	[VideoLink] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[ModuleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uq_course_title] UNIQUE NONCLUSTERED 
(
	[CourseID] ASC,
	[Title] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderItems]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderItems](
	[OrderItemID] [int] IDENTITY(1,1) NOT NULL,
	[OrderID] [int] NOT NULL,
	[UserAccountID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[OrderItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Schedule]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Schedule](
	[ScheduleID] [int] IDENTITY(1,1) NOT NULL,
	[StudyProgramID] [int] NOT NULL,
	[Semester] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ScheduleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ShoppingCart]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ShoppingCart](
	[CartID] [int] IDENTITY(1,1) NOT NULL,
	[UserAccountID] [int] NOT NULL,
	[Status] [varchar](20) NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CartID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StudyPrograms]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StudyPrograms](
	[StudyProgramID] [int] IDENTITY(1,1) NOT NULL,
	[StudyID] [int] NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](1000) NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[NumberOfSpots] [int] NOT NULL,
	[Notes] [nvarchar](1000) NULL,
PRIMARY KEY CLUSTERED 
(
	[StudyProgramID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [unique_program_title] UNIQUE NONCLUSTERED 
(
	[StudyID] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WebinarAccess]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WebinarAccess](
	[WebinarAccessID] [int] IDENTITY(1,1) NOT NULL,
	[UserAccountID] [int] NOT NULL,
	[WebinarID] [int] NOT NULL,
	[AccessGranted] [datetime] NOT NULL,
	[AccessExpires] [datetime] NOT NULL,
	[PaymentID] [int] NULL,
	[AccessType] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[WebinarAccessID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Attendance] ADD  DEFAULT ((0)) FOR [IsPresent]
GO
ALTER TABLE [dbo].[Internships] ADD  DEFAULT ('In progress') FOR [Status]
GO
ALTER TABLE [dbo].[Products] ADD  DEFAULT ('PLN') FOR [CurrencyCode]
GO
ALTER TABLE [dbo].[Studies] ADD  DEFAULT ('polish') FOR [Language]
GO
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_IsRegistered]  DEFAULT ((1)) FOR [IsRegistered]
GO
ALTER TABLE [dbo].[Webinars] ADD  DEFAULT ((0)) FOR [IsTranslated]
GO
ALTER TABLE [dbo].[Webinars] ADD  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[Attendance]  WITH CHECK ADD  CONSTRAINT [fk_enrollment] FOREIGN KEY([EnrollmentID])
REFERENCES [dbo].[Enrollments] ([EnrollmentID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Attendance] CHECK CONSTRAINT [fk_enrollment]
GO
ALTER TABLE [dbo].[CartItems]  WITH CHECK ADD  CONSTRAINT [fk_cartid] FOREIGN KEY([CartID])
REFERENCES [dbo].[ShoppingCart] ([CartID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CartItems] CHECK CONSTRAINT [fk_cartid]
GO
ALTER TABLE [dbo].[CartItems]  WITH CHECK ADD  CONSTRAINT [fk_productid] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
GO
ALTER TABLE [dbo].[CartItems] CHECK CONSTRAINT [fk_productid]
GO
ALTER TABLE [dbo].[Diplomas]  WITH CHECK ADD  CONSTRAINT [fk_courseid] FOREIGN KEY([CourseID])
REFERENCES [dbo].[Courses] ([CourseID])
GO
ALTER TABLE [dbo].[Diplomas] CHECK CONSTRAINT [fk_courseid]
GO
ALTER TABLE [dbo].[Diplomas]  WITH CHECK ADD  CONSTRAINT [fk_diplomas_userid] FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[Diplomas] CHECK CONSTRAINT [fk_diplomas_userid]
GO
ALTER TABLE [dbo].[Enrollments]  WITH CHECK ADD  CONSTRAINT [fk_enrollments_courses] FOREIGN KEY([CourseID])
REFERENCES [dbo].[Courses] ([CourseID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Enrollments] CHECK CONSTRAINT [fk_enrollments_courses]
GO
ALTER TABLE [dbo].[Enrollments]  WITH CHECK ADD  CONSTRAINT [fk_enrollments_studies] FOREIGN KEY([StudyID])
REFERENCES [dbo].[Studies] ([StudyID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Enrollments] CHECK CONSTRAINT [fk_enrollments_studies]
GO
ALTER TABLE [dbo].[Enrollments]  WITH CHECK ADD  CONSTRAINT [fk_enrollments_users] FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Enrollments] CHECK CONSTRAINT [fk_enrollments_users]
GO
ALTER TABLE [dbo].[Enrollments]  WITH CHECK ADD  CONSTRAINT [fk_enrollments_webinars] FOREIGN KEY([WebinarID])
REFERENCES [dbo].[Webinars] ([WebinarID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Enrollments] CHECK CONSTRAINT [fk_enrollments_webinars]
GO
ALTER TABLE [dbo].[Exams]  WITH CHECK ADD  CONSTRAINT [fk_exams_studyid] FOREIGN KEY([StudyID])
REFERENCES [dbo].[Studies] ([StudyID])
GO
ALTER TABLE [dbo].[Exams] CHECK CONSTRAINT [fk_exams_studyid]
GO
ALTER TABLE [dbo].[Exams]  WITH CHECK ADD  CONSTRAINT [fk_exams_userid] FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[Exams] CHECK CONSTRAINT [fk_exams_userid]
GO
ALTER TABLE [dbo].[Internships]  WITH CHECK ADD  CONSTRAINT [fk_internship_studyprogramid] FOREIGN KEY([StudyProgramID])
REFERENCES [dbo].[StudyPrograms] ([StudyProgramID])
GO
ALTER TABLE [dbo].[Internships] CHECK CONSTRAINT [fk_internship_studyprogramid]
GO
ALTER TABLE [dbo].[Internships]  WITH CHECK ADD  CONSTRAINT [fk_internship_userid] FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[Internships] CHECK CONSTRAINT [fk_internship_userid]
GO
ALTER TABLE [dbo].[Lecturers]  WITH CHECK ADD  CONSTRAINT [fk_lecturers_courseid] FOREIGN KEY([CourseID])
REFERENCES [dbo].[Courses] ([CourseID])
GO
ALTER TABLE [dbo].[Lecturers] CHECK CONSTRAINT [fk_lecturers_courseid]
GO
ALTER TABLE [dbo].[Lecturers]  WITH CHECK ADD  CONSTRAINT [fk_lecturers_userid] FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[Lecturers] CHECK CONSTRAINT [fk_lecturers_userid]
GO
ALTER TABLE [dbo].[Modules]  WITH CHECK ADD  CONSTRAINT [fk_course] FOREIGN KEY([CourseID])
REFERENCES [dbo].[Courses] ([CourseID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Modules] CHECK CONSTRAINT [fk_course]
GO
ALTER TABLE [dbo].[OrderItems]  WITH CHECK ADD FOREIGN KEY([OrderID])
REFERENCES [dbo].[Orders] ([OrderID])
GO
ALTER TABLE [dbo].[OrderItems]  WITH CHECK ADD FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
GO
ALTER TABLE [dbo].[OrderItems]  WITH CHECK ADD FOREIGN KEY([UserAccountID])
REFERENCES [dbo].[UsersAccount] ([UserAccountID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Payment] FOREIGN KEY([PaymentID])
REFERENCES [dbo].[Payments] ([PaymentID])
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_Payment]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_UserAccount] FOREIGN KEY([UserAccountID])
REFERENCES [dbo].[UsersAccount] ([UserAccountID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_UserAccount]
GO
ALTER TABLE [dbo].[Payments]  WITH CHECK ADD FOREIGN KEY([CurrencyID])
REFERENCES [dbo].[Currency] ([CurrencyID])
GO
ALTER TABLE [dbo].[Payments]  WITH CHECK ADD FOREIGN KEY([UserAccountID])
REFERENCES [dbo].[UsersAccount] ([UserAccountID])
GO
ALTER TABLE [dbo].[Products]  WITH CHECK ADD FOREIGN KEY([CourseID])
REFERENCES [dbo].[Courses] ([CourseID])
GO
ALTER TABLE [dbo].[Products]  WITH CHECK ADD FOREIGN KEY([CurrencyCode])
REFERENCES [dbo].[Currency] ([CurrencyCode])
GO
ALTER TABLE [dbo].[Products]  WITH CHECK ADD FOREIGN KEY([SessionID])
REFERENCES [dbo].[Sessions] ([SessionID])
GO
ALTER TABLE [dbo].[Products]  WITH CHECK ADD FOREIGN KEY([StudyID])
REFERENCES [dbo].[Studies] ([StudyID])
GO
ALTER TABLE [dbo].[Products]  WITH CHECK ADD FOREIGN KEY([WebinarID])
REFERENCES [dbo].[Webinars] ([WebinarID])
GO
ALTER TABLE [dbo].[Schedule]  WITH CHECK ADD  CONSTRAINT [fk_programid] FOREIGN KEY([StudyProgramID])
REFERENCES [dbo].[StudyPrograms] ([StudyProgramID])
GO
ALTER TABLE [dbo].[Schedule] CHECK CONSTRAINT [fk_programid]
GO
ALTER TABLE [dbo].[Sessions]  WITH CHECK ADD  CONSTRAINT [fk_session_scheduleid] FOREIGN KEY([ScheduleID])
REFERENCES [dbo].[Schedule] ([ScheduleID])
GO
ALTER TABLE [dbo].[Sessions] CHECK CONSTRAINT [fk_session_scheduleid]
GO
ALTER TABLE [dbo].[Sessions]  WITH CHECK ADD  CONSTRAINT [fk_session_userid] FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[Sessions] CHECK CONSTRAINT [fk_session_userid]
GO
ALTER TABLE [dbo].[Sessions]  WITH CHECK ADD  CONSTRAINT [fk_studyid] FOREIGN KEY([StudyID])
REFERENCES [dbo].[Studies] ([StudyID])
GO
ALTER TABLE [dbo].[Sessions] CHECK CONSTRAINT [fk_studyid]
GO
ALTER TABLE [dbo].[ShoppingCart]  WITH CHECK ADD FOREIGN KEY([UserAccountID])
REFERENCES [dbo].[UsersAccount] ([UserAccountID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[StudyPrograms]  WITH CHECK ADD  CONSTRAINT [fk_study_program] FOREIGN KEY([StudyID])
REFERENCES [dbo].[Studies] ([StudyID])
GO
ALTER TABLE [dbo].[StudyPrograms] CHECK CONSTRAINT [fk_study_program]
GO
ALTER TABLE [dbo].[UsersAccount]  WITH CHECK ADD  CONSTRAINT [fk_user_account] FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UsersAccount] CHECK CONSTRAINT [fk_user_account]
GO
ALTER TABLE [dbo].[WebinarAccess]  WITH CHECK ADD  CONSTRAINT [fk_paymentid] FOREIGN KEY([PaymentID])
REFERENCES [dbo].[Payments] ([PaymentID])
GO
ALTER TABLE [dbo].[WebinarAccess] CHECK CONSTRAINT [fk_paymentid]
GO
ALTER TABLE [dbo].[WebinarAccess]  WITH CHECK ADD  CONSTRAINT [fk_user_account_id] FOREIGN KEY([UserAccountID])
REFERENCES [dbo].[UsersAccount] ([UserAccountID])
GO
ALTER TABLE [dbo].[WebinarAccess] CHECK CONSTRAINT [fk_user_account_id]
GO
ALTER TABLE [dbo].[WebinarAccess]  WITH CHECK ADD  CONSTRAINT [fk_webinarid] FOREIGN KEY([WebinarID])
REFERENCES [dbo].[Webinars] ([WebinarID])
GO
ALTER TABLE [dbo].[WebinarAccess] CHECK CONSTRAINT [fk_webinarid]
GO
ALTER TABLE [dbo].[Webinars]  WITH CHECK ADD  CONSTRAINT [fk_instructor] FOREIGN KEY([InstructorID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[Webinars] CHECK CONSTRAINT [fk_instructor]
GO
ALTER TABLE [dbo].[Attendance]  WITH CHECK ADD  CONSTRAINT [chk_is_present] CHECK  (([IsPresent]=(1) OR [IsPresent]=(0)))
GO
ALTER TABLE [dbo].[Attendance] CHECK CONSTRAINT [chk_is_present]
GO
ALTER TABLE [dbo].[Attendance]  WITH CHECK ADD  CONSTRAINT [chk_session_date] CHECK  (([SessionDate]<=sysdatetime()))
GO
ALTER TABLE [dbo].[Attendance] CHECK CONSTRAINT [chk_session_date]
GO
ALTER TABLE [dbo].[CartItems]  WITH CHECK ADD CHECK  (([Quantity]>=(1)))
GO
ALTER TABLE [dbo].[Courses]  WITH CHECK ADD  CONSTRAINT [valid_course_dates] CHECK  (([StartDate]<[EndDate]))
GO
ALTER TABLE [dbo].[Courses] CHECK CONSTRAINT [valid_course_dates]
GO
ALTER TABLE [dbo].[Currency]  WITH CHECK ADD CHECK  (([ExchangeRate]>(0)))
GO
ALTER TABLE [dbo].[Diplomas]  WITH CHECK ADD  CONSTRAINT [valid_issent] CHECK  (([IsSent]=(1) OR [IsSent]=(0)))
GO
ALTER TABLE [dbo].[Diplomas] CHECK CONSTRAINT [valid_issent]
GO
ALTER TABLE [dbo].[Diplomas]  WITH CHECK ADD  CONSTRAINT [valid_issued_date] CHECK  (([IssuedDate]<=getdate()))
GO
ALTER TABLE [dbo].[Diplomas] CHECK CONSTRAINT [valid_issued_date]
GO
ALTER TABLE [dbo].[Exams]  WITH CHECK ADD CHECK  (([ExamScore]>=(0) AND [ExamScore]<=(5)))
GO
ALTER TABLE [dbo].[Internships]  WITH CHECK ADD  CONSTRAINT [valid_end_date] CHECK  (([EndDate]<=dateadd(year,(3),getdate())))
GO
ALTER TABLE [dbo].[Internships] CHECK CONSTRAINT [valid_end_date]
GO
ALTER TABLE [dbo].[Internships]  WITH CHECK ADD  CONSTRAINT [valid_internship_dates] CHECK  (([StartDate]<=[EndDate]))
GO
ALTER TABLE [dbo].[Internships] CHECK CONSTRAINT [valid_internship_dates]
GO
ALTER TABLE [dbo].[Internships]  WITH CHECK ADD  CONSTRAINT [valid_status] CHECK  (([Status]='Cancelled' OR [Status]='Completed' OR [Status]='In progress'))
GO
ALTER TABLE [dbo].[Internships] CHECK CONSTRAINT [valid_status]
GO
ALTER TABLE [dbo].[OrderItems]  WITH CHECK ADD CHECK  (([Quantity]>(0)))
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [CHK_OrderDate] CHECK  (([OrderDate]<=getdate()))
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [CHK_OrderDate]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [CHK_OrderStatus] CHECK  (([OrderStatus]='Cancelled' OR [OrderStatus]='Sent' OR [OrderStatus]='In progress'))
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [CHK_OrderStatus]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [CHK_OrderTotal] CHECK  (([OrderTotal]>=(0)))
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [CHK_OrderTotal]
GO
ALTER TABLE [dbo].[Payments]  WITH CHECK ADD CHECK  (([PaymentStatus]='Failed' OR [PaymentStatus]='Completed' OR [PaymentStatus]='Pending'))
GO
ALTER TABLE [dbo].[Products]  WITH CHECK ADD  CONSTRAINT [chk_price_positive] CHECK  (([Price]>(0.00)))
GO
ALTER TABLE [dbo].[Products] CHECK CONSTRAINT [chk_price_positive]
GO
ALTER TABLE [dbo].[Products]  WITH CHECK ADD  CONSTRAINT [chk_product_type] CHECK  (([ProductType]='Study' OR [ProductType]='Course' OR [ProductType]='Webinar'))
GO
ALTER TABLE [dbo].[Products] CHECK CONSTRAINT [chk_product_type]
GO
ALTER TABLE [dbo].[Products]  WITH CHECK ADD CHECK  (([Price]>=(0.00)))
GO
ALTER TABLE [dbo].[Schedule]  WITH CHECK ADD  CONSTRAINT [chk_valid_dates] CHECK  (([StartDate]<[EndDate]))
GO
ALTER TABLE [dbo].[Schedule] CHECK CONSTRAINT [chk_valid_dates]
GO
ALTER TABLE [dbo].[Sessions]  WITH CHECK ADD CHECK  (([NumberOfSpots]>=(0)))
GO
ALTER TABLE [dbo].[Sessions]  WITH CHECK ADD CHECK  (([SessionType]='hybrid' OR [SessionType]='online' OR [SessionType]='stationary'))
GO
ALTER TABLE [dbo].[Sessions]  WITH CHECK ADD  CONSTRAINT [valid_sessiondate] CHECK  (([SessionDate]>'1900-01-01'))
GO
ALTER TABLE [dbo].[Sessions] CHECK CONSTRAINT [valid_sessiondate]
GO
ALTER TABLE [dbo].[ShoppingCart]  WITH CHECK ADD CHECK  (([CreatedAt]<=getdate()))
GO
ALTER TABLE [dbo].[ShoppingCart]  WITH CHECK ADD CHECK  (([Status]='Abandoned' OR [Status]='Completed' OR [Status]='Active'))
GO
ALTER TABLE [dbo].[Studies]  WITH CHECK ADD CHECK  (([EntryFee]>=(0)))
GO
ALTER TABLE [dbo].[Studies]  WITH CHECK ADD CHECK  (([NumberOfSpots]>=(0)))
GO
ALTER TABLE [dbo].[Studies]  WITH CHECK ADD  CONSTRAINT [valid_dates] CHECK  (([StartDate]<[EndDate]))
GO
ALTER TABLE [dbo].[Studies] CHECK CONSTRAINT [valid_dates]
GO
ALTER TABLE [dbo].[StudyPrograms]  WITH CHECK ADD CHECK  (([NumberOfSpots]>(0)))
GO
ALTER TABLE [dbo].[StudyPrograms]  WITH CHECK ADD  CONSTRAINT [valid_program_dates] CHECK  (([StartDate]<[EndDate]))
GO
ALTER TABLE [dbo].[StudyPrograms] CHECK CONSTRAINT [valid_program_dates]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [check_postal_code] CHECK  (([PostalCode] like '[0-9][0-9]-[0-9][0-9][0-9]'))
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [check_postal_code]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD CHECK  (([Role]='Guest' OR [Role]='Director' OR [Role]='Translator' OR [Role]='Registrar' OR [Role]='Student' OR [Role]='Coordinator' OR [Role]='Instructor' OR [Role]='Administrator'))
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [users_valid_email] CHECK  (([EmailAddress] like '%_@_%._%'))
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [users_valid_email]
GO
ALTER TABLE [dbo].[UsersAccount]  WITH CHECK ADD  CONSTRAINT [check_created_at] CHECK  (([CreatedAt]<=getdate()))
GO
ALTER TABLE [dbo].[UsersAccount] CHECK CONSTRAINT [check_created_at]
GO
ALTER TABLE [dbo].[UsersAccount]  WITH CHECK ADD  CONSTRAINT [check_password_format] CHECK  ((patindex('%[A-Z]%',[PasswordHash])>(0) AND patindex('%[0-9]%',[PasswordHash])>(0) AND patindex('%[^A-Za-z0-9]%',[PasswordHash])>(0)))
GO
ALTER TABLE [dbo].[UsersAccount] CHECK CONSTRAINT [check_password_format]
GO
ALTER TABLE [dbo].[UsersAccount]  WITH CHECK ADD  CONSTRAINT [check_passwordhash_not_empty] CHECK  (([PasswordHash]<>''))
GO
ALTER TABLE [dbo].[UsersAccount] CHECK CONSTRAINT [check_passwordhash_not_empty]
GO
ALTER TABLE [dbo].[UsersAccount]  WITH CHECK ADD  CONSTRAINT [check_username_length] CHECK  ((len([Username])>=(3)))
GO
ALTER TABLE [dbo].[UsersAccount] CHECK CONSTRAINT [check_username_length]
GO
ALTER TABLE [dbo].[UsersAccount]  WITH CHECK ADD  CONSTRAINT [check_username_not_empty] CHECK  (([Username]<>''))
GO
ALTER TABLE [dbo].[UsersAccount] CHECK CONSTRAINT [check_username_not_empty]
GO
ALTER TABLE [dbo].[WebinarAccess]  WITH CHECK ADD  CONSTRAINT [chk_webinar_payments] CHECK  (([AccessType]='Free' OR [PaymentID] IS NOT NULL))
GO
ALTER TABLE [dbo].[WebinarAccess] CHECK CONSTRAINT [chk_webinar_payments]
GO
ALTER TABLE [dbo].[WebinarAccess]  WITH CHECK ADD  CONSTRAINT [valid_access_dates] CHECK  (([AccessGranted]<[AccessExpires]))
GO
ALTER TABLE [dbo].[WebinarAccess] CHECK CONSTRAINT [valid_access_dates]
GO
ALTER TABLE [dbo].[WebinarAccess]  WITH CHECK ADD  CONSTRAINT [valid_access_type] CHECK  (([AccessType]='Paid' OR [AccessType]='Free'))
GO
ALTER TABLE [dbo].[WebinarAccess] CHECK CONSTRAINT [valid_access_type]
GO
ALTER TABLE [dbo].[Webinars]  WITH CHECK ADD  CONSTRAINT [chk_access_link_availability] CHECK  (([AccessLink] IS NULL OR getdate()<=dateadd(minute,(-10),[DateTime])))
GO
ALTER TABLE [dbo].[Webinars] CHECK CONSTRAINT [chk_access_link_availability]
GO
ALTER TABLE [dbo].[Webinars]  WITH CHECK ADD  CONSTRAINT [chk_translator_data] CHECK  (([IsTranslated]=(0) AND [TranslatorFirstName] IS NULL AND [TranslatorLastName] IS NULL OR [IsTranslated]=(1) AND [TranslatorFirstName] IS NOT NULL AND [TranslatorLastName] IS NOT NULL))
GO
ALTER TABLE [dbo].[Webinars] CHECK CONSTRAINT [chk_translator_data]
GO
ALTER TABLE [dbo].[Webinars]  WITH CHECK ADD  CONSTRAINT [chk_video_link_availability] CHECK  (([VideoLink] IS NULL OR getdate()>[DateTime]))
GO
ALTER TABLE [dbo].[Webinars] CHECK CONSTRAINT [chk_video_link_availability]
GO
ALTER TABLE [dbo].[Webinars]  WITH CHECK ADD CHECK  (([Duration]>(0)))
GO
/****** Object:  StoredProcedure [dbo].[AccessWebinarMaterials]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AccessWebinarMaterials]
    @WebinarID INT,
    @UserID INT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Orders o
        JOIN OrderItems oi ON o.OrderID = oi.OrderID
        WHERE o.UserAccountID = @UserID AND oi.ProductID = @WebinarID AND o.OrderStatus = 'Sent'
    )
    BEGIN
        SELECT VideoLink
        FROM Webinars
        WHERE WebinarID = @WebinarID;
    END
    ELSE
    BEGIN
        RAISERROR ('No access to webinar’s material. Process payment to get access.', 16, 1);
    END
END;

GO
/****** Object:  StoredProcedure [dbo].[AddAdministrator]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddAdministrator]
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @EmailAddress NVARCHAR(150),
    @PhoneNumber VARCHAR(9),
    @Username VARCHAR(50),
    @PasswordHash VARCHAR(255)
AS
BEGIN
    INSERT INTO Users (FirstName, LastName, EmailAddress, PhoneNumber, Role, IsRegistered)
    VALUES (@FirstName, @LastName, @EmailAddress, @PhoneNumber, 'Administrator', 0);
    
    
    DECLARE @UserID INT = SCOPE_IDENTITY();

   
    INSERT INTO UsersAccount (UserID, Username, PasswordHash, CreatedAt)
    VALUES (@UserID, @Username, @PasswordHash, GETDATE());
    
     UPDATE Users SET IsRegistered = 1 WHERE UserID = @UserID;
    
    SELECT 'Administrator account added successfully' AS Message;
END;

GO
/****** Object:  StoredProcedure [dbo].[AddCoordinatorAccount]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddCoordinatorAccount]
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @EmailAddress NVARCHAR(150),
    @PhoneNumber VARCHAR(9),
    @Username VARCHAR(50),
    @PasswordHash VARCHAR(255)
AS
BEGIN
     INSERT INTO Users (FirstName, LastName, EmailAddress, PhoneNumber, Role, IsRegistered)
    VALUES (@FirstName, @LastName, @EmailAddress, @PhoneNumber, 'Coordinator', 0);
    
   
    DECLARE @UserID INT = SCOPE_IDENTITY();

        INSERT INTO UsersAccount (UserID, Username, PasswordHash, CreatedAt)
    VALUES (@UserID, @Username, @PasswordHash, GETDATE());
    
       UPDATE Users SET IsRegistered = 1 WHERE UserID = @UserID;
    
    SELECT 'Coordinator account created successfully' AS Message;
END;

GO
/****** Object:  StoredProcedure [dbo].[AddCourse]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AddCourse]
    @Title NVARCHAR(255),
    @Description NVARCHAR(MAX),
    @StartDate DATETIME,
    @EndDate DATETIME,
    @IsHybrid BIT
AS
BEGIN
    INSERT INTO Courses (Title, Description, StartDate, EndDate, IsHybrid)
    VALUES (@Title, @Description, @StartDate, @EndDate, @IsHybrid);
END;

GO
/****** Object:  StoredProcedure [dbo].[AddCurrency]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddCurrency]
    @CurrencyName VARCHAR(50), 
    @CurrencyCode VARCHAR(10),
    @ExchangeRate DECIMAL(10, 4)
AS
BEGIN
    INSERT INTO Currency (CurrencyName, CurrencyCode, ExchangeRate )  
    VALUES (@CurrencyName, @CurrencyCode, @ExchangeRate );
END;
GO
/****** Object:  StoredProcedure [dbo].[AddExam]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddExam]
    @UserID INT, 
    @StudyID INT,
    @ExamDate DATETIME, 
    @ExamScore DECIMAL(3, 2)
AS
BEGIN
    INSERT INTO Exams (UserID, StudyID, ExamDate, ExamScore)    VALUES (@UserID, @StudyID, @ExamDate, @ExamScore);
END;
GO
/****** Object:  StoredProcedure [dbo].[AddInstructorAccount]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddInstructorAccount]
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @EmailAddress NVARCHAR(150),
    @PhoneNumber VARCHAR(9),
    @Username VARCHAR(50),
    @PasswordHash VARCHAR(255)
AS
BEGIN
    
    INSERT INTO Users (FirstName, LastName, EmailAddress, PhoneNumber, Role, IsRegistered)
    VALUES (@FirstName, @LastName, @EmailAddress, @PhoneNumber, 'Instructor', 0);
    
    
    DECLARE @UserID INT = SCOPE_IDENTITY();

   
    INSERT INTO UsersAccount (UserID, Username, PasswordHash, CreatedAt)
    VALUES (@UserID, @Username, @PasswordHash, GETDATE());
    
    UPDATE Users SET IsRegistered = 1 WHERE UserID = @UserID;
    
    SELECT 'Instructor account created successfully' AS Message;
END;

GO
/****** Object:  StoredProcedure [dbo].[AddInternship]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddInternship]
    @UserID INT, 
    @StartDate DATETIME, 
    @EndDate DATETIME, 
    @Status VARCHAR(20) = 'In progress',
    @StudyProgramID INT, 
    @Year INT, 
    @Period INT
AS
BEGIN
    INSERT INTO Internships (UserID, StartDate, EndDate, Status, StudyProgramID, Year, Period )    
    VALUES (@UserID, @StartDate, @EndDate, @Status, @StudyProgramID, @Year, @Period );
END;
GO
/****** Object:  StoredProcedure [dbo].[AddLecturer]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AddLecturer]
    @UserID INT, @CourseID INT
AS
BEGIN
    INSERT INTO Lecturers (UserID, CourseID)
    VALUES (@UserID, @CourseID);
END;

GO
/****** Object:  StoredProcedure [dbo].[AddModuleTranslation]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AddModuleTranslation]
    @ModuleID INT,
    @Translation NVARCHAR(MAX)
AS
BEGIN
    INSERT INTO ModuleTranslations (ModuleID, Translation)
    VALUES (@ModuleID, @Translation);
END;

GO
/****** Object:  StoredProcedure [dbo].[AddPayment]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddPayment]
    @PaymentID INT, 
    @UserAccountID INT, 
    @CurrencyID INT, 
    @PaymentStatus VARCHAR(20), 
    @PaymentDate DATETIME
AS
BEGIN
    INSERT INTO Payments (PaymentID, UserAccountID, CurrencyID, PaymentStatus, PaymentDate )    
    VALUES (@PaymentID, @UserAccountID, @CurrencyID, @PaymentStatus, @PaymentDate );
END;
GO
/****** Object:  StoredProcedure [dbo].[AddRegistrar]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddRegistrar]
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @EmailAddress NVARCHAR(150),
    @PhoneNumber VARCHAR(9),
    @Username VARCHAR(50),
    @PasswordHash VARCHAR(255)
AS
BEGIN
    
    INSERT INTO Users (FirstName, LastName, EmailAddress, PhoneNumber, Role, IsRegistered)
    VALUES (@FirstName, @LastName, @EmailAddress, @PhoneNumber, 'Registrar', 0);
    
    DECLARE @UserID INT = SCOPE_IDENTITY();

    INSERT INTO UsersAccount (UserID, Username, PasswordHash, CreatedAt)
    VALUES (@UserID, @Username, @PasswordHash, GETDATE());
    
    UPDATE Users SET IsRegistered = 1 WHERE UserID = @UserID;
    
    SELECT 'Registrar account added successfully' AS Message;
END;

GO
/****** Object:  StoredProcedure [dbo].[AddSchedule]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddSchedule]
    @StudyProgramID INT, 
    @Semester INT, 
    @StartDate DATETIME, 
    @EndDate DATETIME
AS
BEGIN
    INSERT INTO Schedule (StudyProgramID, Semester, StartDate, EndDate )   
    VALUES (@StudyProgramID, @Semester, @StartDate, @EndDate );
END;
GO
/****** Object:  StoredProcedure [dbo].[AddSession]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AddSession]
    @ScheduleID INT, 
    @StudyID INT, 
    @SessionDate DATETIME, 
    @SessionType VARCHAR(20), 
    @Topic VARCHAR(255), 
    @NumberOfSpots INT, 
    @Notes TEXT = NULL
AS
BEGIN
    INSERT INTO Sessions (ScheduleID, StudyID, SessionDate, SessionType, Topic, NumberOfSpots, Notes )
    VALUES (@ScheduleID, @StudyID, @SessionDate, @SessionType, @Topic, @NumberOfSpots, @Notes );
END;
GO
/****** Object:  StoredProcedure [dbo].[AddShoppingCart]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddShoppingCart]
    @UserAccountID INT, 
    @Status VARCHAR(20), 
    @CreatedAt DATETIME
AS
BEGIN
    INSERT INTO ShoppingCart (UserAccountID, Status, CreatedAt )   
    VALUES (@UserAccountID, @Status, @CreatedAt );
END;
GO
/****** Object:  StoredProcedure [dbo].[AddStudentAccount]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddStudentAccount]
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @EmailAddress NVARCHAR(150),
    @PhoneNumber VARCHAR(9),
    @Role NVARCHAR(50),
    @Username VARCHAR(50),
    @PasswordHash VARCHAR(255)
AS
BEGIN
    
    INSERT INTO Users (FirstName, LastName, EmailAddress, PhoneNumber, Role, IsRegistered)
    VALUES (@FirstName, @LastName, @EmailAddress, @PhoneNumber, 'Student', 0);
    
    DECLARE @UserID INT = SCOPE_IDENTITY();


    INSERT INTO UsersAccount (UserID, Username, PasswordHash, CreatedAt)
    VALUES (@UserID, @Username, @PasswordHash, GETDATE());
    
   
    UPDATE Users SET IsRegistered = 1 WHERE UserID = @UserID;
    
    SELECT 'Account created successfully' AS Message;
END;
GO
/****** Object:  StoredProcedure [dbo].[AddStudy]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AddStudy]
    @Title NVARCHAR(100),
    @Program TEXT,
    @StartDate DATETIME,
    @EndDate DATETIME,
    @NumberOfSpots INT,
    @EntryFee DECIMAL(10, 2),
    @Language NVARCHAR(50),
    @Description TEXT
AS
BEGIN
    INSERT INTO Studies (Title, Program, StartDate, EndDate, NumberOfSpots, EntryFee, Language, Description)
    VALUES (@Title, @Program, @StartDate, @EndDate, @NumberOfSpots, @EntryFee, @Language, @Description);
END;
GO
/****** Object:  StoredProcedure [dbo].[AddStudyProgram]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddStudyProgram]
    @StudyID INT, 
    @Name NVARCHAR(255), 
    @Description NVARCHAR(1000) = NULL, 
    @StartDate DATETIME, 
    @EndDate DATETIME, 
    @NumberOfSpots INT, 
    @Notes NVARCHAR(1000) = NULL
AS
BEGIN
    INSERT INTO StudyPrograms (StudyID, Name, Description, StartDate, EndDate, NumberOfSpots, Notes )  
    VALUES (@StudyID, @Name, @Description, @StartDate, @EndDate, @NumberOfSpots, @Notes );
END;
GO
/****** Object:  StoredProcedure [dbo].[AddToCart]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddToCart]
    @CartID INT,
    @ProductID INT,
    @Quantity INT
AS
BEGIN
    INSERT INTO CartItems (CartID, ProductID, Quantity)
    VALUES (@CartID, @ProductID, @Quantity);
END;

GO
/****** Object:  StoredProcedure [dbo].[AddTranslatorAccount]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddTranslatorAccount]
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @EmailAddress NVARCHAR(150),
    @PhoneNumber VARCHAR(9),
    @Username VARCHAR(50),
    @PasswordHash VARCHAR(255)
AS
BEGIN
    
    INSERT INTO Users (FirstName, LastName, EmailAddress, PhoneNumber, Role, IsRegistered)
    VALUES (@FirstName, @LastName, @EmailAddress, @PhoneNumber, 'Translator', 0);
 
    DECLARE @UserID INT = SCOPE_IDENTITY();

    INSERT INTO UsersAccount (UserID, Username, PasswordHash, CreatedAt)
    VALUES (@UserID, @Username, @PasswordHash, GETDATE());
    
    
    UPDATE Users SET IsRegistered = 1 WHERE UserID = @UserID;
    
    SELECT 'Translator account created successfully' AS Message;
END;

GO
/****** Object:  StoredProcedure [dbo].[AddWebinar]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddWebinar]
    @Title NVARCHAR(255),
    @InstructorID INT,
    @Description NVARCHAR(1000),
    @DateTime DATETIME,
    @Duration INT,
    @Language NVARCHAR(50)
AS
BEGIN
    INSERT INTO Webinars (Title, InstructorID, Description, DateTime, Duration, Language, IsFree)
    VALUES (@Title, @InstructorID, @Description, @DateTime, @Duration, @Language, 0);
END;

GO
/****** Object:  StoredProcedure [dbo].[AddWebinarTranslation]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddWebinarTranslation]
    @WebinarID INT,
    @TranslatorFirstName NVARCHAR(100),
    @TranslatorLastName NVARCHAR(100)
AS
BEGIN
    UPDATE Webinars
    SET IsTranslated = 1, TranslatorFirstName = @TranslatorFirstName, TranslatorLastName = @TranslatorLastName
    WHERE WebinarID = @WebinarID;
END;

GO
/****** Object:  StoredProcedure [dbo].[AssignParticipantsToGroups]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AssignParticipantsToGroups]
    @WebinarID INT,
    @GroupName NVARCHAR(100),
    @ParticipantIDs NVARCHAR(MAX)
AS
BEGIN
   
    DECLARE @ID NVARCHAR(10);
    DECLARE @Pos INT;

    WHILE CHARINDEX(',', @ParticipantIDs) > 0
    BEGIN
        SET @Pos = CHARINDEX(',', @ParticipantIDs);
        SET @ID = LEFT(@ParticipantIDs, @Pos - 1);

        INSERT INTO WebinarGroups (WebinarID, GroupName, ParticipantID)
        VALUES (@WebinarID, @GroupName, CAST(@ID AS INT));

        SET @ParticipantIDs = SUBSTRING(@ParticipantIDs, @Pos + 1, LEN(@ParticipantIDs));
    END;

        INSERT INTO WebinarGroups (WebinarID, GroupName, ParticipantID)
    VALUES (@WebinarID, @GroupName, CAST(@ParticipantIDs AS INT));
END;

GO
/****** Object:  StoredProcedure [dbo].[AssignTranslator]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AssignTranslator]
    @TranslatorID INT,
    @CourseID INT
AS
BEGIN
    INSERT INTO Translators (UserID, CourseID)
    VALUES (@TranslatorID, @CourseID);
END;

GO
/****** Object:  StoredProcedure [dbo].[AssignTranslatorToWebinar]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AssignTranslatorToWebinar]
    @WebinarID INT,
    @TranslatorFirstName NVARCHAR(100),
    @TranslatorLastName NVARCHAR(100)
AS
BEGIN
    UPDATE Webinars
    SET TranslatorFirstName = @TranslatorFirstName, TranslatorLastName = @TranslatorLastName, IsTranslated = 1
    WHERE WebinarID = @WebinarID;
END;

GO
/****** Object:  StoredProcedure [dbo].[DeactivateCoordinatorAccount]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeactivateCoordinatorAccount]
    @UserID INT
AS
BEGIN
        IF EXISTS (SELECT 1 FROM Users WHERE UserID = @UserID AND Role = 'Coordinator')
    BEGIN
        UPDATE Users SET IsRegistered = 0 WHERE UserID = @UserID;
        SELECT 'Coordinator account deactivated successfully' AS Message;
    END
    ELSE
    BEGIN
        SELECT 'No such coordinator account found' AS Message;
    END
END;

GO
/****** Object:  StoredProcedure [dbo].[DeactivateInstructorAccount]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeactivateInstructorAccount]
    @UserID INT
AS
BEGIN
        IF EXISTS (SELECT 1 FROM Users WHERE UserID = @UserID AND Role = 'Instructor')
    BEGIN
        UPDATE Users SET IsRegistered = 0 WHERE UserID = @UserID;
        SELECT 'Instructor account deactivated successfully' AS Message;
    END
    ELSE
    BEGIN
        SELECT 'No such instructor account found' AS Message;
    END
END;

GO
/****** Object:  StoredProcedure [dbo].[DeactivateTranslatorAccount]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeactivateTranslatorAccount]
    @UserID INT
AS
BEGIN
     IF EXISTS (SELECT 1 FROM Users WHERE UserID = @UserID AND Role = 'Translator')
    BEGIN
        UPDATE Users SET IsRegistered = 0 WHERE UserID = @UserID;
        SELECT 'Translator account deactivated successfully' AS Message;
    END
    ELSE
    BEGIN
        SELECT 'No such translator account found' AS Message;
    END
END;

GO
/****** Object:  StoredProcedure [dbo].[DeleteAdministrator]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteAdministrator]
    @UserID INT
AS
BEGIN
        IF EXISTS (SELECT 1 FROM Users WHERE UserID = @UserID AND Role = 'Administrator')
    BEGIN
        DELETE FROM UsersAccount WHERE UserID = @UserID;
        DELETE FROM Users WHERE UserID = @UserID;
        SELECT 'Administrator account deleted successfully' AS Message;
    END
    ELSE
    BEGIN
        SELECT 'No such administrator account found' AS Message;
    END
END;

GO
/****** Object:  StoredProcedure [dbo].[DeleteCourse]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE PROCEDURE [dbo].[DeleteCourse]
    @CourseID INT
AS
BEGIN
    DELETE FROM Courses
    WHERE CourseID = @CourseID;
END;

GO
/****** Object:  StoredProcedure [dbo].[DeleteRegistrar]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteRegistrar]
    @UserID INT
AS
BEGIN
        IF EXISTS (SELECT 1 FROM Users WHERE UserID = @UserID AND Role = 'Registrar')
    BEGIN
        DELETE FROM UsersAccount WHERE UserID = @UserID;
        DELETE FROM Users WHERE UserID = @UserID;
        SELECT 'Registrar account deleted successfully' AS Message;
    END
    ELSE
    BEGIN
        SELECT 'No such registrar account found' AS Message;
    END
END;



GO
/****** Object:  StoredProcedure [dbo].[DeleteStudentAccount]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteStudentAccount]
    @UserID INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Users WHERE UserID = @UserID AND Role = 'Student')
    BEGIN
        DELETE FROM UsersAccount WHERE UserID = @UserID;
        DELETE FROM Users WHERE UserID = @UserID;
        
        SELECT 'Student account deleted successfully' AS Message;
    END
    ELSE
    BEGIN
        SELECT 'No such student account found' AS Message;
    END
END;

GO
/****** Object:  StoredProcedure [dbo].[EnrollParticipant]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[EnrollParticipant]
    @UserID INT,
    @CourseID INT
AS
BEGIN
    INSERT INTO Enrollments (UserID, CourseID)
    VALUES (@UserID, @CourseID);
END;
GO
/****** Object:  StoredProcedure [dbo].[GenerateDiploma]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE PROCEDURE [dbo].[GenerateDiploma]
    @UserID INT,
    @CourseID INT
AS
BEGIN
    INSERT INTO Diplomas (UserID, CourseID, IssuedDate, Address, IsSent)
    VALUES (@UserID, @CourseID, GETDATE(), '', 0);
END;

GO
/****** Object:  StoredProcedure [dbo].[GeneratePaymentLink]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GeneratePaymentLink]
    @OrderID INT,
    @PaymentURL NVARCHAR(500) OUTPUT
AS
BEGIN
    SET @PaymentURL = CONCAT('https://paymentgateway.com/pay?orderId=', @OrderID);
END;

GO
/****** Object:  StoredProcedure [dbo].[GetCourseDetails]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetCourseDetails]
    @CourseID INT
AS
BEGIN
    SELECT *
    FROM Courses
    WHERE CourseID = @CourseID;
END;

GO
/****** Object:  StoredProcedure [dbo].[GetStudyDetails]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetStudyDetails]
    @StudyID INT
AS
BEGIN
    SELECT *
    FROM Studies
    WHERE StudyID = @StudyID;
END;
GO
/****** Object:  StoredProcedure [dbo].[GetWebinarDetails]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetWebinarDetails]
    @WebinarID INT
AS
BEGIN
    SELECT *
    FROM Webinars
    WHERE WebinarID = @WebinarID AND IsDeleted = 0;
END;

GO
/****** Object:  StoredProcedure [dbo].[GrantCourseAccess]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GrantCourseAccess]
    @UserID INT,
    @CourseID INT
AS
BEGIN
    UPDATE Enrollments
    SET CourseID = @CourseID
    WHERE UserID = @UserID;
END;
GO
/****** Object:  StoredProcedure [dbo].[GrantFreeAccess]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GrantFreeAccess]
    @UserID INT,
    @CourseID INT
AS
BEGIN
    INSERT INTO Enrollments (UserID, CourseID)
    VALUES (@UserID, @CourseID);
END;

GO
/****** Object:  StoredProcedure [dbo].[MakeWebinarFree]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MakeWebinarFree]
    @WebinarID INT
AS
BEGIN
    UPDATE Webinars
    SET IsFree = 1
    WHERE WebinarID = @WebinarID;
END;

GO
/****** Object:  StoredProcedure [dbo].[ManageModules]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ManageModules]
    @Action NVARCHAR(10), -- 'Add', 'Update', 'Delete'
    @ModuleID INT = NULL,
    @CourseID INT = NULL,
    @Title NVARCHAR(255) = NULL,
    @ModuleType NVARCHAR(50) = NULL,
    @Location NVARCHAR(255) = NULL
AS
BEGIN
    IF @Action = 'Add'
        INSERT INTO Modules (CourseID, Title, ModuleType, Location)
        VALUES (@CourseID, @Title, @ModuleType, @Location);
    ELSE IF @Action = 'Update'
        UPDATE Modules
        SET Title = @Title, ModuleType = @ModuleType, Location = @Location
        WHERE ModuleID = @ModuleID;
    ELSE IF @Action = 'Delete'
        DELETE FROM Modules
        WHERE ModuleID = @ModuleID;
END;

GO
/****** Object:  StoredProcedure [dbo].[ManageWebinarRecordingAccess]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ManageWebinarRecordingAccess]
    @WebinarID INT,
    @AccessLink NVARCHAR(500)
AS
BEGIN
    UPDATE Webinars
    SET AccessLink = @AccessLink
    WHERE WebinarID = @WebinarID;
END;

GO
/****** Object:  StoredProcedure [dbo].[ModifyStudy]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ModifyStudy]
    @StudyID INT,
    @Title NVARCHAR(100),
    @Program TEXT,
    @StartDate DATETIME,
    @EndDate DATETIME,
    @NumberOfSpots INT,
    @EntryFee DECIMAL(10, 2),
    @Language NVARCHAR(50),
    @Description TEXT
AS
BEGIN
    UPDATE Studies
    SET Title = @Title,
        Program = @Program,
        StartDate = @StartDate,
        EndDate = @EndDate,
        NumberOfSpots = @NumberOfSpots,
        EntryFee = @EntryFee,
        Language = @Language,
        Description = @Description
    WHERE StudyID = @StudyID;
END;
GO
/****** Object:  StoredProcedure [dbo].[ModifyWebinar]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ModifyWebinar]
    @WebinarID INT,
    @Title NVARCHAR(255),
    @Description NVARCHAR(1000),
    @DateTime DATETIME,
    @Duration INT
AS
BEGIN
    UPDATE Webinars
    SET Title = @Title, Description = @Description, DateTime = @DateTime, Duration = @Duration
    WHERE WebinarID = @WebinarID;
END;

GO
/****** Object:  StoredProcedure [dbo].[PayForStudy]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PayForStudy]
    @OrderID INT,
    @PaymentID INT
AS
BEGIN
    UPDATE Orders
    SET PaymentID = @PaymentID, OrderStatus = 'Sent'
    WHERE OrderID = @OrderID;
END;

GO
/****** Object:  StoredProcedure [dbo].[PlaceOrder]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PlaceOrder]
    @UserAccountID INT,
    @CartID INT
AS
BEGIN
    DECLARE @OrderTotal DECIMAL(10, 2) = 0;

    SELECT @OrderTotal = SUM(ci.Quantity * p.Price)
    FROM CartItems ci
    JOIN Products p ON ci.ProductID = p.ProductID
    WHERE ci.CartID = @CartID;

    INSERT INTO Orders (UserAccountID, OrderDate, OrderStatus, OrderTotal)
    VALUES (@UserAccountID, GETDATE(), 'In progress', @OrderTotal);

    DECLARE @OrderID INT = SCOPE_IDENTITY();

    INSERT INTO OrderItems (OrderID, UserAccountID, ProductID, Quantity)
    SELECT @OrderID, @UserAccountID, ProductID, Quantity
    FROM CartItems
    WHERE CartID = @CartID;

    UPDATE ShoppingCart
    SET Status = 'Completed'
    WHERE CartID = @CartID;
END;

GO
/****** Object:  StoredProcedure [dbo].[RateCourse]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RateCourse]
    @UserID INT,
    @CourseID INT,
    @Rating INT
AS
BEGIN
    INSERT INTO CourseRatings (UserID, CourseID, Rating)
    VALUES (@UserID, @CourseID, @Rating);
END;

GO
/****** Object:  StoredProcedure [dbo].[RateWebinar]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RateWebinar]
    @WebinarID INT,
    @UserID INT,
    @Rating INT
AS
BEGIN
    INSERT INTO WebinarRatings (WebinarID, UserID, Rating)
    VALUES (@WebinarID, @UserID, @Rating);
END;

GO
/****** Object:  StoredProcedure [dbo].[RegisterParticipantToWebinar]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RegisterParticipantToWebinar]
    @WebinarID INT,
    @UserID INT
AS
BEGIN
    INSERT INTO WebinarParticipants (WebinarID, UserID)
    VALUES (@WebinarID, @UserID);
END;



GO
/****** Object:  StoredProcedure [dbo].[RegisterPayment]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RegisterPayment]
    @PaymentID INT,
    @OrderID INT
AS
BEGIN
    UPDATE Orders
    SET PaymentID = @PaymentID, OrderStatus = 'Sent'
    WHERE OrderID = @OrderID;
END;

GO
/****** Object:  StoredProcedure [dbo].[RemoveFromCart]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RemoveFromCart]
    @CartID INT,
    @ProductID INT
AS
BEGIN
    DELETE FROM CartItems
    WHERE CartID = @CartID AND ProductID = @ProductID;
END;

GO
/****** Object:  StoredProcedure [dbo].[RemoveWebinar]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RemoveWebinar]
    @WebinarID INT
AS
BEGIN
    UPDATE Webinars
    SET IsDeleted = 1
    WHERE WebinarID = @WebinarID;
END;

GO
/****** Object:  StoredProcedure [dbo].[RemoveWebinarRecording]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RemoveWebinarRecording]
    @WebinarID INT
AS
BEGIN
    UPDATE Webinars
    SET VideoLink = NULL
    WHERE WebinarID = @WebinarID;
END;



GO
/****** Object:  StoredProcedure [dbo].[SetCorrespondenceAddress]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SetCorrespondenceAddress]
    @UserID INT,
    @Address NVARCHAR(100),
    @City NVARCHAR(100),
    @PostalCode NVARCHAR(8)
AS
BEGIN
   
    UPDATE Users
    SET Address = @Address, City = @City, PostalCode = @PostalCode
    WHERE UserID = @UserID AND Role = 'Student';

    SELECT 'Correspondence address updated successfully' AS Message;
END;

GO
/****** Object:  StoredProcedure [dbo].[UpdateCourseSchedule]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UpdateCourseSchedule]
    @CourseID INT,
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN
    UPDATE Courses
    SET StartDate = @StartDate, EndDate = @EndDate
    WHERE CourseID = @CourseID;
END;

GO
/****** Object:  StoredProcedure [dbo].[UpdateOrderStatus]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateOrderStatus]
    @OrderID INT,
    @NewStatus VARCHAR(20)
AS
BEGIN
    UPDATE Orders
    SET OrderStatus = @NewStatus
    WHERE OrderID = @OrderID;
END;

GO
/****** Object:  StoredProcedure [dbo].[VerifyAttendance]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[VerifyAttendance]
    @UserID INT,
    @CourseID INT
AS
BEGIN
    SELECT *
    FROM Attendance
    WHERE EnrollmentID = (
        SELECT EnrollmentID 
        FROM Enrollments 
        WHERE UserID = @UserID AND CourseID = @CourseID
    );
END;

GO
/****** Object:  StoredProcedure [dbo].[ViewCoursesAndModules]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ViewCoursesAndModules]
AS
BEGIN
    SELECT C.CourseID, C.Title, C.Description, M.ModuleID, M.Title AS ModuleTitle
    FROM Courses C
    LEFT JOIN Modules M ON C.CourseID = M.CourseID;
END;

GO
/****** Object:  StoredProcedure [dbo].[ViewStudyModules]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ViewStudyModules]
    @StudyID INT
AS
BEGIN
    SELECT StudyProgramID, Name, Description, StartDate, EndDate, NumberOfSpots, Notes
    FROM StudyPrograms
    WHERE StudyID = @StudyID;
END;
GO
/****** Object:  StoredProcedure [dbo].[ViewStudyOffers]    Script Date: 16.02.2025 23:41:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ViewStudyOffers]
AS
BEGIN
    SELECT StudyID, Title, Description, StartDate, EndDate, NumberOfSpots, EntryFee, Language
    FROM Studies
    WHERE StartDate > GETDATE();
END;
GO
USE [master]
GO
ALTER DATABASE [u_stodolki] SET  READ_WRITE 
GO
