create database project;
use project;


create table Employee(
employee_id int primary key,
last_name varchar(50) NOT NULL,
first_name varchar(50) NOT NULL,
title varchar(30),
reports_to int,
levels varchar(10),
birthdate date,
hire_date date,
address varchar(100),
city varchar(50),
state varchar (10),
country varchar(30),
postal_code varchar(30),
phone varchar(20),
fax varchar(30),
email varchar(50)
);

alter table employee
modify column birthdate varchar(50);

alter table employee
modify column hire_date varchar(50);
CREATE TABLE Customer(
customer_id INT PRIMARY KEY,
first_name varchar(50) NOT NULL,
last_name varchar(50) NOT NULL,
company varchar(50),
address varchar(100),
city varchar(50),
state varchar (10),
postal_code varchar(30),
phone varchar(20),
fax varchar(30),
email varchar(50),
support_rep_id int  NOT NULL,
constraint Fk_Customer_Support FOREIGN KEY (support_rep_id)
references Employee(employee_id) ON UPDATE CASCADE on delete cascade
);
create table invoice(invoice_id int primary key, 
customer_id int not null, 
invoice_date date not null, 
billing_address varchar(50) not null, 
billing_state varchar(10) not null,
billing_country varchar(20) not null, 
billing_postal_code varchar(20), 
total decimal(5,2) not null, 
constraint fk_customer foreign key(customer_Id) references Customer(customer_id) on update cascade on delete cascade);

CREATE TABLE Media(
media_type_id int primary key,
name varchar(50)
);

CREATE TABLE Genre(
genre_id int primary key,
name varchar(50)
);
create table Artist(
artist_id int primary key,
name varchar(50)
);


create table Album(
album_id int not null primary key,
title varchar(50),
artist_id int not null 
);

drop table album;

create table track(
track_id int primary key,
nametrack varchar(20),
album_id int not null,
media_type_id int not null ,
genre_id int not null,
composer varchar(50),
milliseconds int, 
bytes int, 
unit_price decimal(10,2)
);
alter table track
rename column name_ to name;
create table playlist_track(playlist_id int not null,
track_id int not null);

create table playlist(playlist_id int Primary key,
name varchar(50));
 
 
 create table invoice_line(invoice_line_id int primary key, 
invoice_id int not null, 
track_id int not null, 
unit_price decimal(5,2) not null,
quantity int not null, 
constraint fk_invoice foreign key(invoice_id) references invoice(invoice_id) on update cascade on delete cascade);

alter table invoice_line
add constraint fk_track foreign key (track_id) references track(track_id) on update cascade on delete cascade;


ALTER TABLE track
add constraint fk_media foreign key(media_type_id) references media(media_type_id) on update cascade on delete cascade;

ALTER TABLE track
add constraint fk_genre foreign key(genre_id) references  genre(genre_id) on update cascade on delete cascade;

ALTER TABLE track
add constraint fk_album foreign key(album_id) references  album(album_id) on update cascade on delete cascade;

ALTER TABLE playlist_track
add constraint fk_playlist_track foreign key(playlist_id) references  playlist(playlist_id) on update cascade on delete cascade;

ALTER TABLE playlist_track
add constraint fk_track_1 foreign key(track_id) references  track(track_id) on update cascade on delete cascade;

ALTER TABLE album
add constraint fk_album_1 foreign key(artist_id) references  artist(artist_id) on update cascade on delete cascade;

alter table customer
add column country varchar(50);


alter table invoice
add column billing_city varchar(50);

select * from album;
select * from artist;
select * from customer;
select * from employee;
select * from genre;
select * from invoice;
select * from invoice_line;
select * from media;
select * from playlist;
select * from playlist_track;

select * from track;
use project;

#set -1 

# Who is the senior most employee based on job title?

select last_name, first_name, title,lower(hire_date) as senior_emp from employee only group by title;

select * from customer;
# Which countries have the most Invoices?
create view country_Invoice
as 
select customer.first_name, customer.last_name, customer.country, 
count(Invoice.Invoice_id) as Number_of_invoices from customer inner join Invoice using (customer_id) 
group by customer.country order by Number_of_invoices DESC;

select * from country_Invoice;

#What are the top 3 values of total invoice?
select * from invoice order by total desc limit 3;

# Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
#Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals

create view city_total
as 
select city, sum(invoice.total) as invoices_total  from customer inner join invoice using (customer_id)
group by customer.city order by invoices_total desc limit 1;

select * from city_total;
#Who is the best customer? The customer who has spent the most money will be declared the best customer. 
#Write a query that returns the person who has spent the most money

create view best_customer
as 
select first_name, last_name, sum(invoice.total) as total_expenses from customer inner join invoice using (customer_id)
order by total_expenses desc limit 1;

select * from best_customer;
# set 2
#Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. 
#Return your list ordered alphabetically by email starting with A


create view rock
as 
select  distinct customer.email,customer.first_name,customer.last_name, genre.name from genre
inner join track using(genre_id)
inner join invoice_line using(track_id)
inner join invoice using (invoice_id)
inner join customer using (customer_id)

where genre.name="Rock" order by customer.email;

select * from rock;

#Lets invite the artists who have written the most rock music in our dataset.
#Write a query that returns the Artist name and total track count of the top 10 rock bands

create view artist_rock_band
as 
select  distinct artist.name,count(album.album_id) as album_count from artist
inner join album using(artist_id)
inner join track using(album_id)
inner join genre using (genre_id)

where genre.name="Rock"
group by artist.name
order by album_count desc limit 10;

select * from artist_rock_band;

#Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. 
#Order by the song length with the longest songs listed first


select name, milliseconds from track where milliseconds > (select avg(milliseconds) from track) order by milliseconds  desc;

# set 3
#Find how much amount is spent by each customer on artists? Write a query to return customer name, artist name and total spent

select customer.first_name, artist.name,sum(invoice.total) as total_spent from customer 
inner join invoice using (customer_id)
inner join invoice_line using(invoice_id)
inner join track using (track_id)
inner join album using (album_id)
inner join artist using (artist_id)
 group by customer.first_name 
 order by total_spent desc;
 
 #We want to find out the most popular music Genre for each country. 
 #We determine the most popular genre as the genre with the highest amount of purchases. 
 #Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres
 
 select customer.country, genre.name , count(invoice.invoice_id)  from customer
 inner join invoice on customer.customer_id=invoice.customer_id
 inner join invoice_line on invoice.invoice_id=invoice_line.invoice_id
 inner join track on track.track_id=invoice_line.track_id
 inner join genre on genre.genre_id=track.genre_id
 group by customer.country
 order by count(invoice.invoice_id) desc;
 
 #Write a query that determines the customer that has spent the most on music for each country. 
 #Write a query that returns the country along with the top customer and how much they spent. 
 #For countries where the top amount spent is shared, provide all customers who spent this amount
 
 use project;
 
 select customer.country, customer.first_name, customer.last_name, sum(invoice.total) from customer
 inner join invoice on customer.customer_id=invoice.customer_id
 inner join invoice_line on invoice.invoice_id=invoice_line.invoice_id
 inner join track on invoice_line.track_id=track.track_id
 group by customer.country
 order by sum(invoice.total) desc;
 