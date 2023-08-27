create database music_store_db;
use music_store_db;

# Q1. Who is the senior most employee based on job title?

select * from employee  
order by levels desc
limit 1;

# Q2. Which countries have the most invoices?

select billing_country, count(billing_country) as no_of_invoices from invoice
group by billing_country
order by no_of_invoices desc;

# Q3. What are the top 3 values of total invoices?

select * from invoice
order by total desc
limit 3;

# Q4. Which city has the best customers? We would like to throw a promotional music festival in the city we made the most money.
#     Write a Query that returns one city which has highest sum of invoice total. Return both the city name and the total sum of invoices.

select billing_city as city, sum(total) as Total_invoice from invoice 
group by billing_city 
order by total_invoice 
desc limit 1;

# Q5. Who has the best customer? The customer who has spent the most money will be declared as the best customer.
#     Write a Query that returns the person who has spent the most money. 

select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total
from customer 
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id, customer.first_name, customer.last_name
order by total desc
limit 1;

# Q6. Write a Query to return the email, first name, last name of all Rock music listeners.
#     Return your list ordered alphabetically by email starting from A.

select DISTINCT customer.email, customer.first_name, customer.last_name, genre.name as genre from customer
inner join invoice on customer.customer_id = invoice.customer_id
inner join invoice_line on invoice.invoice_id = invoice_line.invoice_id
inner join track on invoice_line.track_id = track.track_id
inner join genre on track.genre_id = genre.genre_id
where genre.name = "Rock"
order by customer.email;

# Q7. Lets invite the arists who have written the most Rock music in our dataset.
#     Write a Query that returns the artist name and total track count of the top 10 rock bands.

select artist.artist_id, artist.name, count(artist.artist_id) as no_of_songs from artist
inner join album2 on artist.artist_id = album2.artist_id
inner join track on album2.album_id = track.album_id
inner join genre on track.genre_id = genre.genre_id
where genre.name = "Rock"
group by artist.artist_id, artist.name
order by no_of_songs desc
limit 10;

# Q8. Return the track names that have a song length longer than the average song length. Return the name and milliseconds for each track.
#     Order by the song length with the longest songs listed first.

select name, milliseconds from track 
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc;

# Q9. Find how much ammount is spent by customer on artists?
#     Write a Query to return the customer name, artist name and total spend.

create view best_selling_artist as 
select artist.artist_id, artist.name as artist_name, sum(invoice_line.unit_price * invoice_line.quantity) as total_sales
from invoice_line 
inner join track on invoice_line.track_id = track.track_id
inner join album2 on track.album_id = album2.album_id
inner join artist on album2.album_id = artist.artist_id
group by artist.artist_id, artist_name
order by total_sales desc;

select c.customer_id, c.first_name, c.last_name, bsa.artist_name, sum(il.unit_price * il.quantity) as amount_spent
from customer c 
inner join invoice on c.customer_id = invoice.customer_id
inner join invoice_line il on invoice.invoice_id = il.invoice_id
inner join track on il.track_id = track.track_id
inner join album2 on track.album_id = album2.album_id
inner join best_selling_artist bsa on album2.artist_id = bsa.artist_id
group by c.customer_id, c.first_name, c.last_name, bsa.artist_name
order by amount_spent desc;

# Q10. We want to find out the most popular genre for each country. We determine the most popular genre with the highest amount of purchase.
#      Write a Query which returns each country along with its top genre.

create view country_wise_genre as 
select count(il.quantity) as purchases, c.country, genre.genre_id, genre.name from customer c
inner join invoice on c.customer_id = invoice.customer_id
inner join invoice_line il on invoice.invoice_id = il.invoice_id
inner join track on il.track_id = track.track_id
inner join genre on track.genre_id = genre.genre_id
group by c.country, genre.genre_id, genre.name
order by c.country, purchases desc;

select * from country_wise_genre 
where purchases in (select max(purchases) from country_wise_genre group by country) 
order by purchases desc;

# Q11. Write a Query that determines the customer that has spent the most on music for each country. 
#      Write a Query that returns country along with its top customer and how much they spent. 

create view customer_wise_spending as 
select c.customer_id, c.first_name, c.last_name, c.country, sum(invoice.total) as amount_spent
from customer c
inner join invoice on c.customer_id = invoice.customer_id
group by c.customer_id, c.first_name, c.last_name, c.country
order by amount_spent desc;

select country, first_name, last_name, amount_spent, customer_id from customer_wise_spending 
where amount_spent in (select max(amount_spent) from customer_wise_spending group by country) 
order by amount_spent desc;