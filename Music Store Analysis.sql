
/*	Question Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */
Select * From employee
order by levels desc
limit 1;

/* Q2: Which countries have the most Invoices? */
select count(*) as c, billing_country from invoice
group by billing_country
order by c desc;

/* Q3: What are top 3 values of total invoice? */
select total from invoice
order by total desc
limit 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */
select billing_city, sum(total) as invoice_total 
from invoice
group by billing_city
order by invoice_total desc;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/
select customer.customer_id, customer.first_name, customer.last_name, Round(sum(invoice.total),2) as total_spendings
from customer
Join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id, first_name, last_name
order by total_spendings desc
limit 1;

/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

/*Method 1 */
select Distinct email as Email, first_name as FirstName, last_name as LastName, genre.name as Genre 
from customer
Join invoice on customer.customer_id = invoice.customer_id
Join invoice_line on invoice.invoice_id = invoice_line.invoice_id
Join track on invoice_line.track_id = track.track_id
Join genre on genre.genre_id = track.track_id
where genre.name like 'Rock'
Order by email;

/* Method 2 */
select email, first_name, last_name
from customer
Join invoice on customer.customer_id = invoice.customer_id
Join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in (
	select track_id from track
    join genre on genre.genre_id = track.genre_id 
    where genre.name like 'Rock')
order by email;

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */
select artist.name, count(artist.artist_id) as total_songs
from track
Join album on track.album_id = album.album_id
Join artist on artist.artist_id = album.artist_id
Join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
group by artist.name
order by total_songs desc
limit 10;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
select name, milliseconds 
from track
where milliseconds > (select avg(milliseconds) as average_milliseconds 
                      from track )
order by milliseconds desc;

/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */
WITH best_selling_artist AS (
	SELECT artist.artist_id, artist.name AS artist_name, 
    SUM(invoice_line.unit_price*invoice_line.quantity) AS Total_Sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1,2
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, 
ROUND(SUM(il.unit_price*il.quantity),2) AS Total_Spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

