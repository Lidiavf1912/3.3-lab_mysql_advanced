-- lab de ayer
-- Challenge 1
select a.au_id as 'Author Id',
		a.au_lname as 'Last Name',
        a.au_fname as 'First Name',
        t.title as 'Title',
        p.pub_name as 'Publisher'
from titleauthor as ta
left join authors as a on ta.au_id=a.au_id
left join titles as t on ta.title_id=t.title_id
left join publishers as p on t.pub_id=p.pub_id;

-- Challenge 2
select a.au_id as 'Author Id',
		a.au_lname as 'Last Name',
        a.au_fname as 'First Name',
        p.pub_name as 'Publisher',
        count(t.title) as 'Title Count'
from titleauthor as ta
left join authors as a on ta.au_id=a.au_id
left join titles as t on ta.title_id=t.title_id
left join publishers as p on t.pub_id=p.pub_id
group by a.au_id, p.pub_name
order by `Title Count` desc;

-- Challenge 3
select a.au_id as 'Author Id',
		a.au_lname as 'Last Name',
        a.au_fname as 'First Name',
        sum(s.qty) as 'Total'
from authors as a
left join titleauthor as ta on a.au_id=ta.au_id
left join titles as t on ta.title_id=t.title_id
left join sales as s on t.title_id=s.title_id
group by a.au_id
order by `Total` desc
limit 3;

-- challenge 4
select a.au_id as 'Author Id',
		a.au_lname as 'Last Name',
        a.au_fname as 'First Name',
        coalesce(sum(s.qty), 0) as 'Total'
from authors as a
left join titleauthor as ta on a.au_id=ta.au_id
left join titles as t on ta.title_id=t.title_id
left join sales as s on t.title_id=s.title_id
group by a.au_id, a.au_lname, a.au_fname
order by `Total` desc
limit 23;


-- PASO 1
select 
	t.title_id as 'Title Id',
	a.au_id as 'Author Id',
	t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100 as 'sales_royalty'
from titleauthor as ta
left join authors as a on ta.au_id=a.au_id
left join titles as t on ta.title_id=t.title_id
left join publishers as p on t.pub_id=p.pub_id
left join sales as s on t.title_id=s.title_id;

-- PASO 2
select 
	t.title_id as 'Title Id',
	a.au_id as 'Author Id',
	sum(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100) as 'aggregated_royalty'
from titleauthor as ta
left join authors as a on ta.au_id=a.au_id
left join titles as t on ta.title_id=t.title_id
left join publishers as p on t.pub_id=p.pub_id
left join sales as s on t.title_id=s.title_id
group by a.au_id, t.title_id;

-- PASO 3
select 
	ta.au_id as 'Author Id',
	sum(t.advance + t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100) as 'profits_royalty'
from titleauthor as ta
inner join titles as t on ta.title_id=t.title_id
inner join sales as s on t.title_id=s.title_id
group by ta.au_id, t.title_id
order by profits_royalty desc
limit 3;

-- Challenge 2
CREATE TEMPORARY TABLE temp_royalties AS
SELECT
    a.au_id AS 'AUTHOR ID',
    SUM(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100) AS 'AGGREGATED_ROYALTIES'
FROM
    titleauthor ta
LEFT JOIN authors a ON ta.au_id = a.au_id
LEFT JOIN titles t ON ta.title_id = t.title_id
LEFT JOIN sales s ON t.title_id = s.title_id
GROUP BY 'AUTHOR ID';

-- segunda tabla
CREATE TEMPORARY TABLE temp_advances AS
SELECT
    a.au_id AS 'AUTHOR ID',
    SUM(titles.advance) AS 'TOTAL_ADVANCE'
FROM
    titleauthor ta
LEFT JOIN authors a ON ta.au_id = a.au_id
LEFT JOIN titles t ON ta.title_id = t.title_id
GROUP BY `AUTHOR ID`;

-- Total earnings (royalties - advances) for each author
CREATE TEMPORARY TABLE temp_earnings AS
SELECT
    temp_royalties.`AUTHOR ID`,
    (temp_royalties.`AGGREGATED_ROYALTIES` - IFNULL(temp_advances.`TOTAL_ADVANCE`, 0)) AS `TOTAL EARNINGS`
FROM temp_royalties
LEFT JOIN temp_advances ON temp_royalties.`AUTHOR ID` = temp_advances.`AUTHOR ID`;

-- Final result with author names
SELECT
    a.au_id AS 'AUTHOR ID',
    a.au_lname AS 'LAST NAME',
    a.au_fname AS 'FIRST NAME',
    temp_earnings.`TOTAL EARNINGS`
FROM authors a
LEFT JOIN temp_earnings ON a.au_id = temp_earnings.`AUTHOR ID`;


-- Challenge 3
CREATE TABLE best_selling_authors (
    id INT PRIMARY KEY NOT NULL,
    au_id VARCHAR(20),
    profits VARCHAR(20)
);
INSERT INTO best_selling_authors(au_id, profits)
SELECT
    tempa.`AUTHOR ID` AS `au_id`,
    (tempa.`AGGREGATED ROYALTIES` + t.advance) AS `profits`
FROM temp_advanced tempa
INNER JOIN titles t ON tempa.`TITLE ID` = t.title_id
ORDER BY `profits` DESC
LIMIT 3;




